import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/leave_request_service.dart';

class ParentLeaveRequestScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const ParentLeaveRequestScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ParentLeaveRequestScreen> createState() => _ParentLeaveRequestScreenState();
}

class _ParentLeaveRequestScreenState extends State<ParentLeaveRequestScreen> {
  final _reasonController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isLoadingHistory = true;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    final list = await LeaveRequestService().getMyRequests();
    if (mounted) {
      setState(() {
        _history = list.where((item) => item['student']?['id'] == widget.studentId).toList();
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do xin nghỉ phép.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);

    final res = await LeaveRequestService().submitLeaveRequest(
      studentId: widget.studentId,
      startDate: startStr,
      endDate: endStr,
      reason: reason,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (res['success'] == true) {
        _reasonController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi đơn xin nghỉ phép thành công! Chờ giáo viên duyệt.'),
            backgroundColor: Colors.green,
          ),
        );
        _loadHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Gửi đơn thất bại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn xin nghỉ - ${widget.studentName}'),
        backgroundColor: AppColors.primaryOf(context),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Soạn Đơn
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tạo đơn xin nghỉ phép mới',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      leading: const Icon(Icons.date_range, color: Colors.blue),
                      title: const Text('Khoảng thời gian nghỉ:'),
                      subtitle: Text(
                        '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _pickDateRange,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Lý do xin nghỉ',
                        hintText: 'Ví dụ: Cháu bị ốm, gia đình có việc bận...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOf(context),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi đơn tới giáo viên'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lịch sử đơn
            const Text(
              'Lịch sử đơn đã gửi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _isLoadingHistory
                ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                : _history.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Chưa có đơn xin nghỉ phép nào.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          final status = item['status'] ?? 'PENDING';
                          Color statusColor = Colors.orange;
                          String statusText = 'Chờ duyệt';

                          if (status == 'APPROVED') {
                            statusColor = Colors.green;
                            statusText = 'Đã duyệt';
                          } else if (status == 'REJECTED') {
                            statusColor = Colors.red;
                            statusText = 'Từ chối';
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item['startDate']} → ${item['endDate']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Chip(
                                        label: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        backgroundColor: statusColor,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                  Text('Lý do: ${item['reason'] ?? ''}'),
                                  if (item['teacherNote'] != null && item['teacherNote'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'GV phản hồi: ${item['teacherNote']}',
                                      style: TextStyle(color: Colors.blue.shade800, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
