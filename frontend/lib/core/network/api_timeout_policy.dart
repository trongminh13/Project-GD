/// Chính sách thời gian chờ (Timeout) phân tầng theo loại tác vụ mạng
enum ApiTimeoutPolicy {
  /// Đọc dữ liệu nhanh (profile, dashboard stats, thời khóa biểu, danh sách lớp): 8 giây
  fastRead(Duration(seconds: 8)),

  /// Cập nhật dữ liệu thông thường (điểm danh, nộp bài, đổi mật khẩu): 15 giây
  mutation(Duration(seconds: 15)),

  /// Tải tệp lên/xuống dung lượng lớn (import Excel, tải PDF sách, upload ảnh): 60 giây
  upload(Duration(seconds: 60)),

  /// Giao dịch tài chính / thanh toán học phí (kèm đối soát trạng thái): 30 giây
  transactional(Duration(seconds: 30));

  final Duration duration;
  const ApiTimeoutPolicy(this.duration);
}
