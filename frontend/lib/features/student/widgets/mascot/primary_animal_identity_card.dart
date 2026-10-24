import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/primary_palette.dart';
export 'package:ashadeep/core/theme/primary_palette.dart';
import 'animal_mascot_data.dart';
import 'animal_mascot_painter.dart';
import 'primary_sky_greeting_header.dart';

/// Thẻ Con Vật Nhận Diện Lớp Học (Dành riêng cho học sinh Cấp 1)
/// Thiết kế chuẩn mực Senior Design: Bo góc 16px, ô con 8px, viền 1.5px, 100% Vector Canvas
/// Tích hợp Header Bầu Trời (Mặt trời/Mặt trăng nhô nửa trên) và Các khung box đa sắc Pastel sống động
class PrimaryAnimalIdentityCard extends StatelessWidget {
  final String studentName;
  final String className;
  final String dateStr;
  final String dobDMY;
  final String teacherName;
  final DateTime? timeOverride;
  final VoidCallback? onTapMore;
  final VoidCallback? onLogout;

  const PrimaryAnimalIdentityCard({
    super.key,
    required this.studentName,
    required this.className,
    required this.dateStr,
    required this.dobDMY,
    required this.teacherName,
    this.timeOverride,
    this.onTapMore,
    this.onLogout,
  });

  // Bảng màu Đa sắc Pastel tinh tế (Playful Multi-Tone Pastel Palette)
  static const PrimaryBoxStyle classStyle = PrimaryPalette.skyBlue;
  static const PrimaryBoxStyle dateStyle = PrimaryPalette.warmAmber;
  static const PrimaryBoxStyle studentStyle = PrimaryPalette.sweetBlossom;
  static const PrimaryBoxStyle teacherStyle = PrimaryPalette.freshMint;

  @override
  Widget build(BuildContext context) {
    final mascot = MascotHashUtil.pickAnimal(
      studentName: studentName,
      dobDMY: dobDMY,
    );

    final color = mascot.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFE), // Nền trắng ngà kem mềm mại, êm mắt
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. Banner Bầu Trời: Hình tượng Mặt Trời/Mặt Trăng nhô nửa trên & Lời chào theo thời gian
          PrimarySkyGreetingHeader(
            studentName: studentName,
            primaryColor: color,
            timeOverride: timeOverride,
          ),

          // Phần nội dung chính: Bố cục 2 cột (Cột thông tin 62% + Cột linh vật 38%)
          InkWell(
            onTap: onTapMore,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Cột thông tin 4 ô ĐA SẮC PASTEL (TÊN LỚP, NGÀY, HỌC SINH, GIÁO VIÊN)
                Expanded(
                  flex: 62,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 6, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hàng 1: TÊN LỚP (Sky Blue) và NGÀY (Warm Amber)
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildInfoBox(
                                label: 'TÊN LỚP',
                                value: className.isNotEmpty
                                    ? className
                                    : 'Lớp 1A',
                                style: classStyle,
                                isCompact: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 6,
                              child: _buildInfoBox(
                                label: 'NGÀY',
                                value: dateStr,
                                style: dateStyle,
                                isCompact: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Hàng 2: HỌC SINH (Sweet Blossom Pink - Hero Highlight)
                        _buildInfoBox(
                          label: 'HỌC SINH',
                          value: studentName.isNotEmpty
                              ? studentName
                              : 'Học sinh Đại Việt',
                          style: studentStyle,
                          isHighlight: true,
                        ),
                        const SizedBox(height: 8),

                        // Hàng 3: GIÁO VIÊN (Fresh Mint Emerald)
                        _buildInfoBox(
                          label: 'GIÁO VIÊN',
                          value: teacherName.isNotEmpty
                              ? teacherName
                              : 'Cô Nguyễn Thị Lan',
                          style: teacherStyle,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: color.withValues(alpha: 0.35),
                                width: 1.0,
                              ),
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
            color: color.withValues(alpha: 0.15),
          ),

          // Thanh tác vụ và thông tin bạn đồng hành dưới cùng (Đa sắc Pastel sinh động)
          Container(
            color: const Color(0xFFFAFBFC),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Khẩu hiệu bạn đồng hành: Dải capsule vàng bơ pastel
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9C3), // Vàng bơ nhạt
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDE047),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 13,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            mascot.greeting,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFA16207),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF5F3FF,
                            ), // Tím Lavender pastel
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFC4B5FD),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                size: 13,
                                color: Color(0xFF6D28D9),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tiện ích',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6D28D9),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFF1F2,
                            ), // Hồng Soft Rose pastel
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFECDD3),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout,
                                size: 13,
                                color: Color(0xFFBE123C),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFBE123C),
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

  /// Helper xây dựng từng ô thông tin: Bo góc 8px, viền 1.5px, màu sắc pastel nhạt không đổ màu 1 hướng
  Widget _buildInfoBox({
    required String label,
    required String value,
    required PrimaryBoxStyle style,
    bool isHighlight = false,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: isCompact ? 5 : 6),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: style.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nhãn Label (TÊN LỚP, NGÀY, HỌC SINH, GIÁO VIÊN)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: style.tagBgColor,
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
              color: style.textColor,
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
