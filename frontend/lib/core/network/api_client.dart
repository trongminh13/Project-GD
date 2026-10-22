import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ashadeep/core/network/api_exceptions.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/core/network/network_cache_manager.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/utils/constants.dart';

/// Hàm giải mã JSON chạy trong background isolate để tránh gây jank/drop frame cho Main UI thread
dynamic _parseJsonInBackground(List<int> bytes) {
  final string = utf8.decode(bytes);
  return jsonDecode(string);
}

class ApiClient {
  static final http.Client _sharedHttpClient = http.Client();
  static final ApiClient _instance = ApiClient._internal();

  /// Singleton instance mặc định của toàn bộ ứng dụng, sử dụng chung Persistent Connection Pool
  static ApiClient get instance => _instance;

  final http.Client _client;
  final AuthService _authService;
  final String? _baseUrl;
  final NetworkCacheManager _cacheManager;

  /// Bộ nhớ tạm gộp các request GET trùng URL đang bay trên mạng (Request Deduplication)
  final Map<String, Future<dynamic>> _inFlightGets = {};

  ApiClient._internal()
      : _client = _sharedHttpClient,
        _authService = AuthService(),
        _baseUrl = null,
        _cacheManager = NetworkCacheManager();

  ApiClient._custom({http.Client? client, AuthService? authService, String? baseUrl, NetworkCacheManager? cacheManager})
      : _client = client ?? _sharedHttpClient,
        _authService = authService ?? AuthService(),
        _baseUrl = baseUrl,
        _cacheManager = cacheManager ?? NetworkCacheManager();

  /// Factory constructor: Nếu không truyền tham số thì trả về Singleton dùng chung connection pool
  factory ApiClient({http.Client? client, AuthService? authService, String? baseUrl}) {
    if (client == null && authService == null && baseUrl == null) {
      return _instance;
    }
    return ApiClient._custom(client: client, authService: authService, baseUrl: baseUrl);
  }

  /// Constructor dành riêng cho Unit Test
  @visibleForTesting
  factory ApiClient.forTesting({http.Client? client, AuthService? authService, String? baseUrl, NetworkCacheManager? cacheManager}) {
    return ApiClient._custom(client: client, authService: authService, baseUrl: baseUrl, cacheManager: cacheManager);
  }

  Future<Map<String, String>> _defaultHeaders({Map<String, String>? extraHeaders}) async {
    final token = await _authService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    String fullUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      fullUrl = path;
    } else {
      final defaultBase = _baseUrl ?? ApiConstants.baseUrl;
      final base = defaultBase.endsWith('/')
          ? defaultBase.substring(0, defaultBase.length - 1)
          : defaultBase;
      final endpoint = path.startsWith('/') ? path : '/$path';
      fullUrl = '$base$endpoint';
    }

    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map((k, v) => MapEntry(k, v?.toString() ?? ''));
      return uri.replace(queryParameters: {...uri.queryParameters, ...stringParams});
    }
    return uri;
  }

  /// Giải mã phản hồi: Tự động đưa payload lớn (>20KB) vào Background Isolate
  Future<dynamic> _decodeBodyBytes(List<int> bytes) async {
    if (bytes.isEmpty) return null;
    try {
      if (bytes.length > 20480 && !kIsWeb) {
        return await compute(_parseJsonInBackground, bytes);
      } else {
        return jsonDecode(utf8.decode(bytes));
      }
    } catch (_) {
      return utf8.decode(bytes);
    }
  }

  Future<dynamic> _processResponse(http.Response response, {String? cacheKey}) async {
    final statusCode = response.statusCode;

    // HTTP 304 Not Modified: Trả về dữ liệu từ memory cache lập tức (0 bytes transferred)
    if (statusCode == 304 && cacheKey != null) {
      final cached = _cacheManager.get(cacheKey);
      if (cached != null) {
        _cacheManager.refreshTimestamp(cacheKey);
        return cached.data;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      final decodedData = await _decodeBodyBytes(response.bodyBytes);
      if (cacheKey != null) {
        final etag = response.headers['etag'];
        _cacheManager.set(cacheKey, data: decodedData, etag: etag);
      }
      return decodedData;
    }

    String message = 'Đã xảy ra lỗi ($statusCode)';
    dynamic errorDetails;
    try {
      if (response.bodyBytes.isNotEmpty) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          message = decoded['message'] ?? decoded['error'] ?? message;
          errorDetails = decoded;
        }
      }
    } catch (_) {}

    switch (statusCode) {
      case 401:
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw ResourceNotFoundException(message);
      default:
        throw ApiException(statusCode, message, details: errorDetails);
    }
  }

  /// Tự động xóa cache các endpoint liên quan khi có đột biến dữ liệu (Mutation)
  void _invalidateRelatedCache(String path) {
    try {
      final uri = Uri.parse(path.startsWith('/') ? path : '/$path');
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        _cacheManager.invalidate(segments.first);
      }
    } catch (_) {}
  }

  /// Thực thi HTTP request với cơ chế Exponential Backoff Retry cho các lỗi mạng gián đoạn
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() action, {
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await action();
      } on SocketException catch (_) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      } on TimeoutException catch (_) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      } on http.ClientException catch (_) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  /// GET request: Hỗ trợ ETag 304 Caching, Request Deduplication, và Retry
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    ApiTimeoutPolicy policy = ApiTimeoutPolicy.fastRead,
    bool useCache = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    final cacheKey = uri.toString();

    // 1. Request Deduplication: Nếu request này đang được gửi đi ngầm, gộp chung Future
    if (useCache && _inFlightGets.containsKey(cacheKey)) {
      return _inFlightGets[cacheKey]!;
    }

    final requestFuture = _performGet(uri, cacheKey, headers: headers, policy: policy, useCache: useCache);
    if (useCache) {
      _inFlightGets[cacheKey] = requestFuture;
    }

    try {
      return await requestFuture;
    } finally {
      if (useCache) {
        _inFlightGets.remove(cacheKey);
      }
    }
  }

  Future<dynamic> _performGet(
    Uri uri,
    String cacheKey, {
    Map<String, String>? headers,
    required ApiTimeoutPolicy policy,
    required bool useCache,
  }) async {
    try {
      final requestHeaders = await _defaultHeaders(extraHeaders: headers);

      // Đính kèm If-None-Match nếu đã có ETag trong memory cache
      if (useCache) {
        final cachedEtag = _cacheManager.getEtag(cacheKey);
        if (cachedEtag != null && cachedEtag.isNotEmpty) {
          requestHeaders['If-None-Match'] = cachedEtag;
        }
      }

      final response = await _executeWithRetry(
        () => _client.get(uri, headers: requestHeaders).timeout(policy.duration),
      );

      return await _processResponse(response, cacheKey: useCache ? cacheKey : null);
    } on ApiException {
      rethrow;
    } catch (e) {
      // Nếu có lỗi mạng nhưng trong cache vẫn còn dữ liệu cũ, trả về dữ liệu cũ (SWR Fallback)
      if (useCache) {
        final cached = _cacheManager.get(cacheKey);
        if (cached != null) {
          return cached.data;
        }
      }
      throw NetworkException('Không thể kết nối đến máy chủ: $e');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    ApiTimeoutPolicy policy = ApiTimeoutPolicy.mutation,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final requestHeaders = await _defaultHeaders(extraHeaders: headers);
      final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
      final response = await _client.post(uri, headers: requestHeaders, body: encodedBody).timeout(policy.duration);
      final result = await _processResponse(response);
      _invalidateRelatedCache(path);
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Không thể gửi dữ liệu lên máy chủ: $e');
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    ApiTimeoutPolicy policy = ApiTimeoutPolicy.mutation,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final requestHeaders = await _defaultHeaders(extraHeaders: headers);
      final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
      final response = await _client.put(uri, headers: requestHeaders, body: encodedBody).timeout(policy.duration);
      final result = await _processResponse(response);
      _invalidateRelatedCache(path);
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Không thể cập nhật dữ liệu: $e');
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    ApiTimeoutPolicy policy = ApiTimeoutPolicy.mutation,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final requestHeaders = await _defaultHeaders(extraHeaders: headers);
      final response = await _client.delete(uri, headers: requestHeaders).timeout(policy.duration);
      final result = await _processResponse(response);
      _invalidateRelatedCache(path);
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Không thể xóa dữ liệu: $e');
    }
  }
}
