import 'package:flutter/material.dart';

/// Cấu hình phong cách màu sắc cho từng khung box bo góc (Đa sắc Pastel vui nhộn, không đổ màu 1 hướng)
class PrimaryBoxStyle {
  final Color bgColor;
  final Color borderColor;
  final Color accentColor;
  final Color textColor;

  const PrimaryBoxStyle({
    required this.bgColor,
    required this.borderColor,
    Color? accentColor,
    Color? tagBgColor,
    required this.textColor,
  })  : accentColor = accentColor ?? (tagBgColor ?? textColor);

  Color get tagBgColor => accentColor;
}

/// Hệ thống Bảng màu Đa sắc Pastel 5 tone tuần hoàn cho học sinh Cấp 1
class PrimaryPalette {
  PrimaryPalette._();

  // Tone 0: Xanh Da Trời Pastel (Sky Blue)
  static const PrimaryBoxStyle skyBlue = PrimaryBoxStyle(
    bgColor: Color(0xFFF0F7FF),
    borderColor: Color(0xFF93C5FD),
    accentColor: Color(0xFF3B82F6),
    textColor: Color(0xFF1E40AF),
  );

  // Tone 1: Vàng Mật Ong / Cam Đào Pastel (Warm Amber)
  static const PrimaryBoxStyle warmAmber = PrimaryBoxStyle(
    bgColor: Color(0xFFFFFBEB),
    borderColor: Color(0xFFFCD34D),
    accentColor: Color(0xFFF59E0B),
    textColor: Color(0xFF92400E),
  );

  // Tone 2: Hồng Dâu Mộng Mơ Pastel (Sweet Blossom Pink)
  static const PrimaryBoxStyle sweetBlossom = PrimaryBoxStyle(
    bgColor: Color(0xFFFDF2F8),
    borderColor: Color(0xFFF472B6),
    accentColor: Color(0xFFEC4899),
    textColor: Color(0xFF9D174D),
  );

  // Tone 3: Xanh Bạc Hà Tươi Mát (Fresh Mint Emerald)
  static const PrimaryBoxStyle freshMint = PrimaryBoxStyle(
    bgColor: Color(0xFFF0FDF4),
    borderColor: Color(0xFF6EE7B7),
    accentColor: Color(0xFF10B981),
    textColor: Color(0xFF065F46),
  );

  // Tone 4: Tím Oải Hương Pastel (Lavender)
  static const PrimaryBoxStyle lavender = PrimaryBoxStyle(
    bgColor: Color(0xFFF5F3FF),
    borderColor: Color(0xFFC4B5FD),
    accentColor: Color(0xFF8B5CF6),
    textColor: Color(0xFF6D28D9),
  );

  static const List<PrimaryBoxStyle> itemStyles = [
    skyBlue,
    warmAmber,
    sweetBlossom,
    freshMint,
    lavender,
  ];

  static PrimaryBoxStyle getStyle(int index) {
    if (index < 0) return itemStyles[0];
    return itemStyles[index % itemStyles.length];
  }
}
