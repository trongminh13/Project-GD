/// Các lớp ngoại lệ chuyên biệt cho tầng mạng và API
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException(this.statusCode, this.message, {this.details});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'])
      : super(401, message);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Bạn không có quyền truy cập tài nguyên này.'])
      : super(403, message);
}

class ResourceNotFoundException extends ApiException {
  ResourceNotFoundException([String message = 'Không tìm thấy dữ liệu yêu cầu.'])
      : super(404, message);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.'])
      : super(0, message);
}
