import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class FeeService {
  static final FeeService _instance = FeeService._internal();
  factory FeeService() => _instance;
  FeeService._internal();

  /// Fetches fee statement from backend
  Future<List<Map<String, dynamic>>> getFeeStatement(String studentId) async {
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
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching fees: $e');
    }
    // No mock data — return empty if API fails
    return [];
  }

  /// Interacts with backend to generate Razorpay Order ID securely
  Future<String?> createRazorpayOrder(String studentId, double amount) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/fees/create-order');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'studentId': studentId, 'amount': amount}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['orderId']; // Backend returns the razorpay order_id
      }
    } catch (e) {
      print('Error creating Razorpay order: $e');
    }
    return null; // No mock order ID
  }

  /// Sends Razorpay signature back to backend to save receipt and mark true
  Future<bool> verifyPayment(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/fees/verify-payment');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying payment: $e');
    }
    return false; // No mock success
  }
}
