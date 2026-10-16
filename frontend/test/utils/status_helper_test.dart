import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/utils/status_helper.dart';

void main() {
  group('StatusHelper Tests', () {
    test('getAttendanceStatus returns correct label and info', () {
      final present = StatusHelper.getAttendanceStatus('PRESENT');
      expect(present.label, 'Có mặt');

      final absent = StatusHelper.getAttendanceStatus('ABSENT');
      expect(absent.label, 'Vắng mặt');

      final late = StatusHelper.getAttendanceStatus('LATE');
      expect(late.label, 'Đi muộn');

      final excused = StatusHelper.getAttendanceStatus('EXCUSED');
      expect(excused.label, 'Nghỉ có phép');

      final fallback = StatusHelper.getAttendanceStatus(null);
      expect(fallback.label, 'Có mặt');
    });

    test('getHomeworkStatus returns correct label', () {
      final graded = StatusHelper.getHomeworkStatus('GRADED');
      expect(graded.label, 'ĐÃ CHẤM ĐIỂM');

      final submitted = StatusHelper.getHomeworkStatus('SUBMITTED');
      expect(submitted.label, 'ĐÃ NỘP (CHỜ CHẤM)');

      final inProgress = StatusHelper.getHomeworkStatus('IN_PROGRESS');
      expect(inProgress.label, 'ĐANG LÀM DỞ');

      final notStarted = StatusHelper.getHomeworkStatus('NOT_STARTED');
      expect(notStarted.label, 'CHƯA LÀM');

      final nullStatus = StatusHelper.getHomeworkStatus(null);
      expect(nullStatus.label, 'CHƯA LÀM');

      final flagGraded = StatusHelper.getHomeworkStatus('SUBMITTED', isGraded: true);
      expect(flagGraded.label, 'ĐÃ CHẤM ĐIỂM');
    });

    test('getLeaveRequestStatus returns correct label', () {
      expect(StatusHelper.getLeaveRequestStatus('APPROVED').label, 'ĐÃ DUYỆT');
      expect(StatusHelper.getLeaveRequestStatus('REJECTED').label, 'TỪ CHỐI');
      expect(StatusHelper.getLeaveRequestStatus('PENDING').label, 'CHỜ DUYỆT');
      expect(StatusHelper.getLeaveRequestStatus(null).label, 'CHỜ DUYỆT');
    });
  });
}
