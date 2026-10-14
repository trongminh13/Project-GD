import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/leave_request_service.dart';

class TeacherLeaveApprovalScreen extends StatefulWidget {
  const TeacherLeaveApprovalScreen({super.key});

  @override
  State<TeacherLeaveApprovalScreen> createState() => _TeacherLeaveApprovalScreenState();
}

class _TeacherLeaveApprovalScreenState extends State<TeacherLeaveApprovalScreen> {
  bool _isLoading = true;
  List<dynamic> _pendingList = [];

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _isLoading = true);
    final list = await LeaveRequestService().getPendingRequestsForTeacher();
    if (mounted) {
      setState(() {
        _pendingList = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _showReviewDialog(int requestId, String studentName, String decision) async {
    final noteController = TextEditingController();
    final isApprove = decision == 'APPROVED';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isApprove ? 'Duyệt đơn nghỉ phép' : 'Từ chối đơn nghỉ phép'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Học sinh: $studentName'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Ghi chú của giáo viên (tùy chọn)',
                hintText: isApprove ? 'Đồng ý, chúc em sớm khỏe!' : 'Lý do từ chối...',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isApprove ? 'Xác nhận duyệt' : 'Xác nhận từ chối'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await LeaveRequestService().reviewLeaveRequest(
        requestId: requestId,
        decision: decision,
        teacherNote: noteController.text.trim(),
      );

      if (mounted) {
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApprove ? 'Đã duyệt đơn nghỉ phép!' : 'Đã từ chối đơn.'),
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
          );
          _loadPendingRequests();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Thao tác thất bại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt đơn xin nghỉ phép'),
        backgroundColor: AppColors.primaryOf(context),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'Không có đơn xin nghỉ phép nào đang chờ duyệt!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingList.length,
                  itemBuilder: (context, index) {
                    final item = _pendingList[index];
                    final student = item['student'] ?? {};
                    final guardian = item['submittedByGuardian'] ?? {};
                    final studentName = student['name'] ?? 'Học sinh';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  studentName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Chờ duyệt',
                                    style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Thời gian: ${item['startDate']} → ${item['endDate']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('Lý do: ${item['reason']}'),
                            Text('Phụ huynh: ${guardian['name'] ?? 'N/A'} (${guardian['phone'] ?? ''})', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  onPressed: () => _showReviewDialog(item['id'], studentName, 'REJECTED'),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Từ chối'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _showReviewDialog(item['id'], studentName, 'APPROVED'),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Duyệt'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
