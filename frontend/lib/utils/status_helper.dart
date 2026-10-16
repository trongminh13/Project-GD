import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

class StatusInfo {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const StatusInfo({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });
}

class StatusHelper {
  StatusHelper._();

  /// Ánh xạ trạng thái Chuyên cần (Attendance)
  static StatusInfo getAttendanceStatus(String? status) {
    final s = (status ?? 'PRESENT').toUpperCase();
    switch (s) {
      case 'ABSENT':
        return StatusInfo(
          label: 'Vắng mặt',
          color: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          icon: Icons.cancel_outlined,
        );
      case 'LATE':
        return StatusInfo(
          label: 'Đi muộn',
          color: AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          icon: Icons.access_time,
        );
      case 'EXCUSED':
        return StatusInfo(
          label: 'Nghỉ có phép',
          color: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          icon: Icons.event_busy_outlined,
        );
      case 'PRESENT':
      default:
        return StatusInfo(
          label: 'Có mặt',
          color: AppColors.success,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          icon: Icons.check_circle_outline,
        );
    }
  }

  /// Ánh xạ trạng thái Bài tập LMS (Homework)
  static StatusInfo getHomeworkStatus(String? status, {bool isGraded = false}) {
    final s = (status ?? 'NOT_STARTED').toUpperCase();
    if (isGraded || s == 'GRADED') {
      return StatusInfo(
        label: 'ĐÃ CHẤM ĐIỂM',
        color: AppColors.success,
        backgroundColor: AppColors.success.withValues(alpha: 0.12),
        icon: Icons.verified_outlined,
      );
    }
    if (s == 'SUBMITTED') {
      return StatusInfo(
        label: 'ĐÃ NỘP (CHỜ CHẤM)',
        color: AppColors.warning,
        backgroundColor: AppColors.warning.withValues(alpha: 0.12),
        icon: Icons.pending_actions_outlined,
      );
    }
    if (s == 'IN_PROGRESS') {
      return StatusInfo(
        label: 'ĐANG LÀM DỞ',
        color: AppColors.primary,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        icon: Icons.edit_note_outlined,
      );
    }
    return StatusInfo(
      label: 'CHƯA LÀM',
      color: AppColors.textSub,
      backgroundColor: AppColors.surfaceAlt,
      icon: Icons.assignment_late_outlined,
    );
  }

  /// Ánh xạ trạng thái Đơn xin nghỉ phép (Leave Request)
  static StatusInfo getLeaveRequestStatus(String? status) {
    final s = (status ?? 'PENDING').toUpperCase();
    switch (s) {
      case 'APPROVED':
        return StatusInfo(
          label: 'ĐÃ DUYỆT',
          color: AppColors.success,
          backgroundColor: AppColors.success.withValues(alpha: 0.12),
          icon: Icons.check_circle,
        );
      case 'REJECTED':
        return StatusInfo(
          label: 'TỪ CHỐI',
          color: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.12),
          icon: Icons.highlight_off,
        );
      case 'PENDING':
      default:
        return StatusInfo(
          label: 'CHỜ DUYỆT',
          color: AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.12),
          icon: Icons.hourglass_top,
        );
    }
  }
}
