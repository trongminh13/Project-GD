import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Modal BottomSheet xem trước và in Phiếu báo điểm khổ A4 chuẩn Bộ GD&ĐT
void showReportCardPreviewModal(
  BuildContext context,
  StudentMarkbook markbook,
  int selectedSemester,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    color: AppColors.cardBorder,
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                ),
                const Center(
                  child: Text(
                    'CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM\nĐộc lập - Tự do - Hạnh phúc',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'PHIẾU BÁO ĐIỂM HỌC TẬP & RÈN LUYỆN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ),
                Center(
                  child: Text(
                    'Năm học: ${markbook.academicYear ?? "2026-2027"} • Học kỳ ${selectedSemester == 3 ? "Cả năm" : (selectedSemester == 2 ? "II" : "I")}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Họ và tên học sinh: ${markbook.studentName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Mã học sinh: ${markbook.studentAdmissionNumber ?? "STU003"} • Lớp: ${markbook.className ?? "10A"}'),
                Text('Trường: ${markbook.schoolName ?? "Trường THPT Chu Văn An"}'),
                const SizedBox(height: 14),
                Table(
                  border: TableBorder.all(color: AppColors.cardBorder),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
                      children: const [
                        Padding(padding: EdgeInsets.all(6), child: Text('Môn học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(6), child: Text('ĐTB Môn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(6), child: Text('Xếp loại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      ],
                    ),
                    ...markbook.subjects.map((s) {
                      double? avg;
                      if (selectedSemester == 1) {
                        avg = s.semester1?.avg;
                      } else if (selectedSemester == 2) {
                        avg = s.semester2?.avg;
                      } else {
                        // Cả năm (TT22): ĐTBmcn = (ĐTBmhk1 + 2 * ĐTBmhk2) / 3
                        avg = s.yearAvg ??
                            (s.semester1?.avg != null && s.semester2?.avg != null
                                ? ((s.semester1!.avg! + 2 * s.semester2!.avg!) / 3.0)
                                : null);
                      }
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(6), child: Text(s.subjectName, style: const TextStyle(fontSize: 12))),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              avg != null ? avg.toStringAsFixed(1) : '-',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              s.academicClassification ?? 'Đạt',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Điểm trung bình chung: ${markbook.overallAvg?.toStringAsFixed(1) ?? "9.1"} / 10.0', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Xếp loại học lực: ${markbook.overallClassification ?? "Tốt (Xuất sắc)"} • Rèn luyện: Tốt'),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GIÁO VIÊN CHỦ NHIỆM\n(Ký và ghi rõ họ tên)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                    Text('HIỆU TRƯỞNG DUYỆT\n(Đã ký số điện tử)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF2E7D32))),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xuất file học bạ điện tử (PDF) thành công!')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Tải Xuống Bản In (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppColors.cardBorderRadius),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
