import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'animal_mascot_data.dart';
import 'animal_mascot_painter.dart';

/// Thẻ Con Vật Nhận Diện Lớp Học (Dành riêng cho học sinh Cấp 1)
/// Thiết kế chuẩn mực Senior Design: Bo góc 16px, ô con 8px, viền 1.5px, 100% Vector Canvas
class PrimaryAnimalIdentityCard extends StatelessWidget {
  final String studentName;
  final String className;
  final String dateStr;
  final String dobDMY;
  final String teacherName;
  final VoidCallback? onTapMore;
  final VoidCallback? onLogout;

  const PrimaryAnimalIdentityCard({
    super.key,
    required this.studentName,
    required this.className,
    required this.dateStr,
    required this.dobDMY,
    required this.teacherName,
    this.onTapMore,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final mascot = MascotHashUtil.pickAnimal(
      studentName: studentName,
      dobDMY: dobDMY,
    );

    final color = mascot.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phần nội dung chính: Bố cục 2 cột (Cột thông tin 62% + Cột linh vật 38%)
          InkWell(
            onTap: onTapMore,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Cột thông tin 4 ô (TÊN LỚP, NGÀY, HỌC SINH, GIÁO VIÊN)
                Expanded(
                  flex: 62,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 6, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hàng 1: TÊN LỚP và NGÀY
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildInfoBox(
                                label: 'TÊN LỚP',
                                value: className.isNotEmpty ? className : 'Lớp 1A',
                                color: color,
                                isCompact: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 6,
                              child: _buildInfoBox(
                                label: 'NGÀY',
                                value: dateStr,
                                color: color,
                                isCompact: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Hàng 2: HỌC SINH
                        _buildInfoBox(
                          label: 'HỌC SINH',
                          value: studentName.isNotEmpty ? studentName : 'Học sinh Astra',
                          color: color,
                          isHighlight: true,
                        ),
                        const SizedBox(height: 8),

                        // Hàng 3: GIÁO VIÊN
                        _buildInfoBox(
                          label: 'GIÁO VIÊN',
                          value: teacherName.isNotEmpty ? teacherName : 'Cô Nguyễn Thị Lan',
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Cột linh vật vẫy tay ở mép phải (CustomPainter Vector)
                Expanded(
                  flex: 38,
                  child: SizedBox(
                    height: 184,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: AnimalMascotPainter(
                              type: mascot.type,
                              primaryColor: color,
                            ),
                          ),
                        ),
                        // Badge tên bạn đồng hành nhỏ xinh ở góc dưới
                        Positioned(
                          left: 4,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pets, size: 11, color: color),
                                const SizedBox(width: 4),
                                Text(
                                  mascot.name,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Đường phân cách mảnh tinh tế
          Divider(
            height: 1,
            thickness: 1,
            color: color.withValues(alpha: 0.2),
          ),

          // Thanh tác vụ và thông tin bạn đồng hành dưới cùng
          Container(
            color: color.withValues(alpha: 0.03),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Khẩu hiệu bạn đồng hành
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          mascot.greeting,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Nhóm nút bấm thao tác (Cài đặt & Tiện ích, Đăng xuất)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onTapMore != null)
                      InkWell(
                        onTap: onTapMore,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.settings_outlined, size: 13, color: color),
                              const SizedBox(width: 4),
                              Text(
                                'Tiện ích',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (onLogout != null) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onLogout,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.35), width: 1.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, size: 13, color: AppColors.error),
                              SizedBox(width: 4),
                              Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper xây dựng từng ô thông tin: Bo góc 8px, viền 1.5px theo màu linh vật, nhãn tag nền màu
  Widget _buildInfoBox({
    required String label,
    required String value,
    required Color color,
    bool isHighlight = false,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nhãn Label (TÊN LỚP, NGÀY, HỌC SINH, GIÁO VIÊN)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 3),

          // Giá trị text
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 17 : (isCompact ? 13.5 : 14.5),
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
