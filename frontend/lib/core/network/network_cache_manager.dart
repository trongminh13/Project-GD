import 'dart:collection';

class CacheEntry {
  final dynamic data;
  final String? etag;
  final DateTime timestamp;
  final Duration maxAge;

  CacheEntry({
    required this.data,
    this.etag,
    DateTime? timestamp,
    this.maxAge = const Duration(minutes: 5),
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > maxAge;
}

/// Trình quản lý bộ nhớ đệm HTTP Client (In-Memory SWR Cache)
/// Lưu trữ phản hồi và ETag để tái sử dụng hoặc gửi If-None-Match đến server.
class NetworkCacheManager {
  static final NetworkCacheManager _instance = NetworkCacheManager._internal();
  factory NetworkCacheManager() => _instance;
  NetworkCacheManager._internal();

  final Map<String, CacheEntry> _cache = HashMap<String, CacheEntry>();

  /// Lấy mục bộ nhớ đệm theo key (URL / Endpoint)
  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    return entry;
  }

  /// Lấy ETag của key nếu có
  String? getEtag(String key) {
    return _cache[key]?.etag;
  }

  /// Lưu dữ liệu và ETag vào bộ nhớ đệm
  void set(
    String key, {
    required dynamic data,
    String? etag,
    Duration maxAge = const Duration(minutes: 5),
  }) {
    _cache[key] = CacheEntry(
      data: data,
      etag: etag,
      timestamp: DateTime.now(),
      maxAge: maxAge,
    );
  }

  /// Cập nhật timestamp của mục cache (khi nhận được 304 Not Modified)
  void refreshTimestamp(String key) {
    final entry = _cache[key];
    if (entry != null) {
      _cache[key] = CacheEntry(
        data: entry.data,
        etag: entry.etag,
        timestamp: DateTime.now(),
        maxAge: entry.maxAge,
      );
    }
  }

  /// Xóa cache theo key hoặc tiền tố/pattern (ví dụ khi có thao tác POST/PUT/DELETE)
  void invalidate(String pattern) {
    _cache.removeWhere((key, _) => key.contains(pattern));
  }

  /// Xóa toàn bộ cache (ví dụ khi đăng xuất)
  void clear() {
    _cache.clear();
  }
}
