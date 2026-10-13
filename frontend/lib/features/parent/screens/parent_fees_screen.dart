import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/fee_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ParentFeesScreen extends StatefulWidget {
  const ParentFeesScreen({super.key});

  @override
  State<ParentFeesScreen> createState() => _ParentFeesScreenState();
}

class _ParentFeesScreenState extends State<ParentFeesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Razorpay _razorpay;

  List<Map<String, dynamic>> _feeComponents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _loadFees();
  }

  Future<void> _loadFees() async {
    setState(() => _isLoading = true);
    // Student ID would normally be passed dynamically from profile selection
    final data = await FeeService().getFeeStatement('student123');
    setState(() {
      _feeComponents = data;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verifying Payment...')));
    bool verified = await FeeService().verifyPayment(
      response.orderId ?? "",
      response.paymentId ?? "",
      response.signature ?? "",
    );

    if (!mounted) return;

    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Payment Successful & Verified!"),
          backgroundColor: AppColors.success,
        ),
      );
      _loadFees(); // Reload fees, moving pending to paid
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to verify signature with server."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: \${response.message}"),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: \${response.walletName}"),
      ),
    );
  }

  void _initiateRazorpayPayment(double amount) async {
    // 1. Ask backend for an Order ID (Required by Razorpay to verify transactions)
    String? orderId = await FeeService().createRazorpayOrder(
      'student123',
      amount,
    );

    // 2. Configure checkout
    var options = {
      'key':
          'TODO_REPLACE_WITH_LIVE_KEY', // <-- REPLACE THIS WITH YOUR TEST APP KEY ID
      'amount': (amount * 100)
          .toInt(), // amount in the smallest currency sub-unit (paise)
      'name': 'Ashadeep School',
      'order_id': orderId, // Pass the Order ID from Backend
      'description': 'Fee Payment',
      'prefill': {'contact': '9876543210', 'email': 'parent@example.com'},
      'theme': {'color': '#ff5e62'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalDue = 0;
    for (var fee in _feeComponents) {
      if (fee['status'] == 'Pending') {
        totalDue += fee['amount'];
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerGradientColors = isDark
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [const Color(0xFF1A237E), const Color(0xFF0D1454)];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fee Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Total Due Card
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: headerGradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Pending",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.school,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 30,
                              ),
                            ],
                          ),
                          Text(
                            "₹${totalDue.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize:
                                  32, // Reduced from 40 to prevent overflow
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Due by 10 Oct 2025",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 2. Fee Breakdown
                    Text(
                      "Fee Breakdown",
                      style: AppTextStyles.heading2(context),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _feeComponents.length,
                      itemBuilder: (context, index) {
                        final fee = _feeComponents[index];
                        final isPaid = fee['status'] == 'Paid';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPaid
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fee['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: AppColors.textTertiaryOf(
                                          context,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Due: ${fee['dueDate']}",
                                        style: TextStyle(
                                          color: AppColors.textSecondaryOf(
                                            context,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹${fee['amount']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (isPaid)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'PAID',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _initiateRazorpayPayment(
                                              (fee['amount'] as num).toDouble(),
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryOf(
                                            context,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          "PAY NOW",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
