import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/core/network/api_exceptions.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/utils/constants.dart';

class ApiClient {
  final http.Client _client;
  final AuthService _authService;
  final String? _baseUrl;

  ApiClient({http.Client? client, AuthService? authService, String? baseUrl})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService(),
        _baseUrl = baseUrl;

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

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.bodyBytes.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        return utf8.decode(response.bodyBytes);
      }
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

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    ApiTimeoutPolicy policy = ApiTimeoutPolicy.fastRead,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final requestHeaders = await _defaultHeaders(extraHeaders: headers);
      final response = await _client.get(uri, headers: requestHeaders).timeout(policy.duration);
      return _processResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
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
      return _processResponse(response);
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
      return _processResponse(response);
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
      return _processResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Không thể xóa dữ liệu: $e');
    }
  }
}
