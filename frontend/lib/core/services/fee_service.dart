import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class FeeService {
  static final FeeService _instance = FeeService._internal();
  factory FeeService() => _instance;
  FeeService._internal();

  /// Fetches raw fee statement map containing pendingFees, paidFees, totalPending
  Future<Map<String, dynamic>> getFeeStatementRaw(String studentId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/fees/statement/$studentId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {}
    return {'pendingFees': [], 'paidFees': [], 'totalPending': 0};
  }

  /// Normalized fee statement for UI presentation
  Future<List<Map<String, dynamic>>> getFeeStatement(String studentId) async {
    final raw = await getFeeStatementRaw(studentId);
    List<Map<String, dynamic>> result = [];

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
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/fees/create-order');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': int.tryParse(studentId) ?? studentId,
          'feeStructureId': feeStructureId,
          'amount': amount,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['orderId'];
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
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/fees/verify-payment');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(() {
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
          return map;
        }()),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }
}
