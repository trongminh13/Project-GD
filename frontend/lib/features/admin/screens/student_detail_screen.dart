import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/models/student.dart';
import 'package:ashadeep/models/fee.dart';
import 'package:intl/intl.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  bool _isAadhaarVisible = false;

  // Mock Fees Data
  final List<Fee> _fees = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text(widget.student.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(context),
            const SizedBox(height: 24),
            Text('Fee Management', style: AppTextStyles.heading2(context)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fees.length,
              itemBuilder: (context, index) {
                final fee = _fees[index];
                // Hide Board Fees if not Class 10 or 12
                if (fee.feeType == 'Board Fees' &&
                    !['10', '12'].contains(widget.student.className)) {
                  return const SizedBox.shrink();
                }
                return _buildFeeItem(context, fee);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryOf(context).withValues(alpha: 0.1),
                backgroundImage: widget.student.photoUrl.startsWith('http')
                    ? NetworkImage(widget.student.photoUrl)
                    : AssetImage(widget.student.photoUrl) as ImageProvider,
                onBackgroundImageError: (_, _) =>
                    const Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.student.name, style: AppTextStyles.heading2(context)),
                    const SizedBox(height: 4),
                    Text(
                      'Class: ${widget.student.className} | Admn No: ${widget.student.admissionNumber}',
                      style: AppTextStyles.body(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gender: ${widget.student.gender}',
                      style: AppTextStyles.body(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          _buildInfoRow(context, 'Father\'s Name', widget.student.fatherName),
          const SizedBox(height: 10),
          _buildInfoRow(context, 'Mother\'s Name', widget.student.motherName),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aadhaar No:',
                style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    _isAadhaarVisible
                        ? widget.student.aadhaar
                        : widget.student.aadhaar.length >= 9
                        ? widget.student.aadhaar.replaceRange(
                            0,
                            9,
                            'XXXX-XXXX-',
                          )
                        : widget.student.aadhaar.isNotEmpty
                        ? 'XXXX'
                        : 'N/A',
                    style: AppTextStyles.body(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAadhaarVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.primaryOf(context),
                    ),
                    onPressed: () {
                      setState(() {
                        _isAadhaarVisible = !_isAadhaarVisible;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
        ),
        Text(value, style: AppTextStyles.body(context)),
      ],
    );
  }

  Widget _buildFeeItem(BuildContext context, Fee fee) {
    Color statusColor;
    IconData statusIcon;

    switch (fee.status) {
      case 'Paid':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'Late':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = AppColors.error;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          fee.feeType,
          style: AppTextStyles.heading2(context).copyWith(fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DueDate: ${DateFormat('dd MMM yyyy').format(fee.dueDate)}',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildFeeHistory(context, fee.feeType),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 14, color: AppColors.primaryOf(context)),
                    const SizedBox(width: 4),
                    Text(
                      'View History',
                      style: TextStyle(
                        color: AppColors.primaryOf(context),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          '₹${fee.amount.toStringAsFixed(0)}',
          style: AppTextStyles.heading2(context).copyWith(fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fee.status == 'Paid')
                  Text(
                    'Paid on: ${DateFormat('dd MMM yyyy').format(fee.paymentDate!)}',
                    style: TextStyle(color: AppColors.success),
                  ),
                if (fee.remarks != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      fee.remarks!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiaryOf(context),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (fee.status != 'Paid')
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.notifications_active),
                          label: const Text('Send Reminder'),
                          onPressed: () {
                            _showSmsSimulationDialog(
                              context,
                              "Dear Parent, current status for ${widget.student.name}'s ${fee.feeType} is PENDING. Please pay ₹${fee.amount} by ${DateFormat('dd MMM').format(fee.dueDate)} to avoid late fees.",
                              "Reminder Sent",
                            );
                          },
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOf(context),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Status',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          // Show Edit Dialog
                          _showEditStatusDialog(context, fee);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSmsSimulationDialog(BuildContext context, String message, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.sms, color: AppColors.secondary),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Simulating SMS sent to registered mobile no:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  message,
                  style: AppTextStyles.body(context).copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEditStatusDialog(BuildContext context, Fee fee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Fee Status for ${fee.feeType}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Mark as Paid'),
                subtitle: const Text('Will send payment confirmation SMS'),
                leading: const Icon(Icons.check_circle, color: AppColors.success),
                onTap: () {
                  setState(() {
                    fee.status = 'Paid';
                    fee.paymentDate = DateTime.now();
                    fee.remarks =
                        'Edited by Admin on ${DateFormat('dd MMM yyyy').format(DateTime.now())}';
                  });
                  Navigator.pop(context);
                  _showSmsSimulationDialog(
                    context,
                    "Dear Parent, received ₹${fee.amount} for ${widget.student.name}'s ${fee.feeType}. Thank you.",
                    "Payment Confirmation",
                  );
                },
              ),
              ListTile(
                title: const Text('Mark as Late & Apply Charge'),
                subtitle: const Text('Adds ₹500 Late Fee'),
                leading: const Icon(Icons.warning, color: Colors.orange),
                onTap: () {
                  setState(() {
                    fee.status = 'Late';
                    // fee.amount += 500; // In a real app we would update amount, but keeping simple for UI demo
                    fee.remarks =
                        'Late Fee (+₹500) Applied by Admin on ${DateFormat('dd MMM yyyy').format(DateTime.now())}';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeeHistory(BuildContext context, String feeType) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$feeType History', style: AppTextStyles.heading2(context)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.check_circle, color: AppColors.success),
            title: const Text('Paid - Jan 2025'),
            subtitle: const Text('Via UPI • 10 Jan 2025'),
            trailing: const Text(
              '₹5,000',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: AppColors.success),
            title: const Text('Paid - Dec 2024'),
            subtitle: const Text('Via Cash • 05 Dec 2024'),
            trailing: const Text(
              '₹5,000',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: const Text('Late Fee - Nov 2024'),
            subtitle: const Text('Paid with Fine • 20 Nov 2024'),
            trailing: const Text(
              '₹5,500',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
