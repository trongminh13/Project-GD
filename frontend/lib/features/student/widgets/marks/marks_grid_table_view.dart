import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Sổ điểm điện tử dạng bảng cuộn ngang (Grid Table View)
class MarksGridTableView extends StatelessWidget {
  final StudentMarkbook markbook;
  final String level;
  final int selectedSemester; // 1: HK1, 2: HK2, 3: Cả năm

  const MarksGridTableView({
    super.key,
    required this.markbook,
    required this.level,
    required this.selectedSemester,
  });

  String _classifyScore(double? avg) {
    if (avg == null) return 'Chưa có điểm';
    if (avg >= 8.0) return 'Tốt';
    if (avg >= 6.5) return 'Khá';
    if (avg >= 5.0) return 'Đạt';
    return 'Chưa đạt';
  }

  @override
  Widget build(BuildContext context) {
    final semLabel = selectedSemester == 2 ? 'HK2' : 'HK1';

    if (selectedSemester == 3) {
      // BẢNG CHUẨN TỔNG KẾT CẢ NĂM (ĐTB HK1, ĐTB HK2, ĐTB CẢ NĂM, XẾP LOẠI)
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 46,
            horizontalMargin: 12,
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F7FA)),
            columns: const [
              DataColumn(label: Text('Môn học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('ĐTB HK1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('ĐTB HK2 (x2)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('ĐTB Cả năm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Xếp loại Cả năm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ],
            rows: markbook.subjects.map((s) {
              final hk1Str = s.semester1?.avg != null ? s.semester1!.avg!.toStringAsFixed(1) : '-';
              final hk2Str = s.semester2?.avg != null ? s.semester2!.avg!.toStringAsFixed(1) : '-';
              final calculatedYearAvg = s.yearAvg ??
                  (s.semester1?.avg != null && s.semester2?.avg != null
                      ? ((s.semester1!.avg! + 2 * s.semester2!.avg!) / 3.0)
                      : null);
              final yearStr = calculatedYearAvg != null ? calculatedYearAvg.toStringAsFixed(1) : '-';
              final classStr = s.academicClassification ??
                  (calculatedYearAvg != null ? _classifyScore(calculatedYearAvg) : 'Đạt');

              return DataRow(cells: [
                DataCell(Text(s.subjectName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                DataCell(Text(hk1Str, style: const TextStyle(fontSize: 11.5))),
                DataCell(Text(hk2Str, style: const TextStyle(fontSize: 11.5))),
                DataCell(Text(yearStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))),
                DataCell(Text(classStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
              ]);
            }).toList(),
          ),
        ),
      );
    }

    // BẢNG ĐIỂM CHI TIẾT TỪNG KỲ (HK1 HOẶC HK2)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 46,
          horizontalMargin: 12,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F7FA)),
          columns: [
            const DataColumn(label: Text('Môn học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('TX $semLabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('GK $semLabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('CK $semLabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('ĐTB $semLabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            const DataColumn(label: Text('ĐTB Năm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            const DataColumn(label: Text('Xếp loại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: markbook.subjects.map((s) {
            final sem = selectedSemester == 2 ? s.semester2 : s.semester1;
            final txStr = (sem?.txScores != null && sem!.txScores.isNotEmpty)
                ? sem.txScores.map((e) => e != null ? e.toStringAsFixed(1) : '-').join(', ')
                : '-';
            final gkStr = sem?.gkScore != null ? sem!.gkScore!.toStringAsFixed(1) : '-';
            final ckStr = sem?.ckScore != null ? sem!.ckScore!.toStringAsFixed(1) : '-';
            final avgStr = sem?.avg != null ? sem!.avg!.toStringAsFixed(1) : '-';
            final calculatedYearAvg = s.yearAvg ??
                (s.semester1?.avg != null && s.semester2?.avg != null
                    ? ((s.semester1!.avg! + 2 * s.semester2!.avg!) / 3.0)
                    : null);
            final yearStr = calculatedYearAvg != null ? calculatedYearAvg.toStringAsFixed(1) : '-';
            final isNarrative = markbook.isNarrativeOnly || (sem != null && sem.avg == null && sem.ckScore == null);
            final classStr = sem?.avg != null
                ? _classifyScore(sem!.avg)
                : (isNarrative ? (s.academicClassification ?? 'Đạt') : 'Chưa có điểm');

            return DataRow(cells: [
              DataCell(Text(s.subjectName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              DataCell(Text(txStr, style: const TextStyle(fontSize: 11.5))),
              DataCell(Text(gkStr, style: const TextStyle(fontSize: 11.5))),
              DataCell(Text(ckStr, style: const TextStyle(fontSize: 11.5))),
              DataCell(Text(avgStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))),
              DataCell(Text(yearStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))),
              DataCell(Text(classStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
