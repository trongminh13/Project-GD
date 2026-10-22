import 'dart:math' as math;
import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';

class FeeService {
  static final FeeService _instance = FeeService._internal();
  factory FeeService() => _instance;
  FeeService._internal() : _apiClient = ApiClient.instance;

  final ApiClient _apiClient;

  /// Sinh mã Idempotency-Key chuẩn UUIDv4 chống trừ tiền 2 lần khi mạng chập chờn
  static String generateIdempotencyKey() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant RFC4122
    final hexChars = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hexChars.sublist(0, 4).join()}-${hexChars.sublist(4, 6).join()}-${hexChars.sublist(6, 8).join()}-${hexChars.sublist(8, 10).join()}-${hexChars.sublist(10, 16).join()}';
  }

  /// Fetches raw fee statement map containing pendingFees, paidFees, totalPending
  Future<Map<String, dynamic>> getFeeStatementRaw(String studentId) async {
    try {
      final res = await _apiClient.get(
        '/fees/statement/$studentId',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (_) {}
    return {'pendingFees': [], 'paidFees': [], 'totalPending': 0};
  }

  /// Normalized fee statement for UI presentation
  Future<List<Map<String, dynamic>>> getFeeStatement(String studentId) async {
    final raw = await getFeeStatementRaw(studentId);
    final List<Map<String, dynamic>> result = [];

    final pending = raw['pendingFees'] as List? ?? [];
    for (var f in pending) {
      result.add({
        'id': f['id'],
        'title': f['feeType'] != null ? '${f['feeType']} Fee' : 'Tuition Fee',
        'dueDate': f['dueMonth'] != null ? 'Month ${f['dueMonth']}' : 'Due Soon',
        'amount': f['amount'] ?? 0,
        'status': 'Pending',
        'feeStructureId': f['id'],
      });
    }

    final paid = raw['paidFees'] as List? ?? [];
    for (var p in paid) {
      final structure = p['feeStructure'];
      String title = 'Tuition Fee';
      if (structure != null && structure is Map && structure['feeType'] != null) {
        title = '${structure['feeType']} Fee';
      }
      result.add({
        'id': p['id'],
        'title': title,
        'dueDate': p['paymentDate'] != null ? 'Paid on ${p['paymentDate']}' : 'Paid',
        'amount': p['amountPaid'] ?? 0,
        'status': 'Paid',
        'transactionId': p['transactionId'],
      });
    }

    return result;
  }

  /// Interacts with backend to generate Razorpay Order ID securely
  Future<String?> createRazorpayOrder(
    String studentId,
    double amount, {
    int? feeStructureId,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? generateIdempotencyKey();
    try {
      final res = await _apiClient.post(
        '/fees/create-order',
        headers: {'Idempotency-Key': key},
        body: {
          'studentId': int.tryParse(studentId) ?? studentId,
          'feeStructureId': feeStructureId,
          'amount': amount,
        },
        policy: ApiTimeoutPolicy.transactional,
      );
      if (res is Map<String, dynamic>) {
        return res['orderId']?.toString();
      }
    } catch (_) {}
    return null;
  }

  /// Sends Razorpay signature back to backend to save receipt and mark true
  Future<bool> verifyPayment(
    String orderId,
    String paymentId,
    String signature, {
    String? studentId,
    int? feeStructureId,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? generateIdempotencyKey();
    try {
      final map = <String, dynamic>{
        'orderId': orderId,
        'razorpayOrderId': orderId,
        'paymentId': paymentId,
        'razorpayPaymentId': paymentId,
        'signature': signature,
        'razorpaySignature': signature,
      };
      if (studentId != null) map['studentId'] = int.tryParse(studentId) ?? studentId;
      if (feeStructureId != null) map['feeStructureId'] = feeStructureId;

      await _apiClient.post(
        '/fees/verify-payment',
        headers: {'Idempotency-Key': key},
        body: map,
        policy: ApiTimeoutPolicy.transactional,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Đối soát trạng thái giao dịch thanh toán khi gặp sự cố mạng/timeout
  Future<Map<String, dynamic>?> checkPaymentStatus(String orderId) async {
    try {
      final res = await _apiClient.get(
        '/fees/order-status/$orderId',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (_) {}
    return null;
  }
}
