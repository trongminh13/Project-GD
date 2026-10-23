import 'package:flutter/material.dart';

enum AnimalMascotType {
  bear,       // Gấu
  crocodile,  // Cá sấu
  cat,        // Mèo
  fish,       // Cá
  horse,      // Ngựa
  rabbit,     // Thỏ
  dog,        // Chó
  elephant,   // Voi
  duck,       // Vịt
  frog,       // Ếch
}

class AnimalMascotModel {
  final AnimalMascotType type;
  final String id;
  final String name;
  final Color primaryColor;
  final String colorName;
  final String greeting;

  const AnimalMascotModel({
    required this.type,
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.colorName,
    required this.greeting,
  });
}

class AnimalMascotData {
  static const List<AnimalMascotModel> allMascots = [
    AnimalMascotModel(
      type: AnimalMascotType.bear,
      id: 'gau',
      name: 'Gấu',
      primaryColor: Color(0xFF0B63C5),
      colorName: 'Xanh nước biển',
      greeting: 'Bạn Gấu Dũng Cảm',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.crocodile,
      id: 'casau',
      name: 'Cá sấu',
      primaryColor: Color(0xFFEE4F8F),
      colorName: 'Hồng',
      greeting: 'Bạn Cá Sấu Dễ Thương',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.cat,
      id: 'meo',
      name: 'Mèo',
      primaryColor: Color(0xFF2F9E4F),
      colorName: 'Xanh lá',
      greeting: 'Bạn Mèo Nhanh Nhẹn',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.fish,
      id: 'ca',
      name: 'Cá',
      primaryColor: Color(0xFFF08A1C),
      colorName: 'Cam',
      greeting: 'Bạn Cá Thông Thái',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.horse,
      id: 'ngua',
      name: 'Ngựa',
      primaryColor: Color(0xFF7B4FC9),
      colorName: 'Tím',
      greeting: 'Bạn Ngựa Kiên Cường',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.rabbit,
      id: 'tho',
      name: 'Thỏ',
      primaryColor: Color(0xFFD63A3A),
      colorName: 'Đỏ',
      greeting: 'Bạn Thỏ Tinh Nghịch',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.dog,
      id: 'cho',
      name: 'Chó',
      primaryColor: Color(0xFF0F9AA8),
      colorName: 'Xanh ngọc',
      greeting: 'Bạn Cún Trung Thành',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.elephant,
      id: 'voi',
      name: 'Voi',
      primaryColor: Color(0xFF8A5A3C),
      colorName: 'Nâu',
      greeting: 'Bạn Voi Tốt Bụng',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.duck,
      id: 'vit',
      name: 'Vịt',
      primaryColor: Color(0xFFD49B00),
      colorName: 'Vàng',
      greeting: 'Bạn Vịt Hoạt Bát',
    ),
    AnimalMascotModel(
      type: AnimalMascotType.frog,
      id: 'ech',
      name: 'Ếch',
      primaryColor: Color(0xFF5FA300),
      colorName: 'Xanh chanh',
      greeting: 'Bạn Ếch Cố Gắng',
    ),
  ];

  static AnimalMascotModel getByIndex(int index) {
    final safeIndex = (index % allMascots.length + allMascots.length) % allMascots.length;
    return allMascots[safeIndex];
  }
}

class MascotHashUtil {
  /// Xóa dấu tiếng Việt, đưa về chữ thường không dấu
  static String stripAccents(String s) {
    const vietnameseMap = {
      'a': 'aáàảãạăắằẳẵặâấầẩẫậ',
      'd': 'dđ',
      'e': 'eéèẻẽẹêếềểễệ',
      'i': 'iíìỉĩị',
      'o': 'oóòỏõọôốồổỗộơớờởỡợ',
      'u': 'uúùủũụưứừửữự',
      'y': 'yýỳỷỹỵ',
    };
    String result = s.toLowerCase();
    vietnameseMap.forEach((nonAccent, accented) {
      for (int i = 0; i < accented.length; i++) {
        result = result.replaceAll(accented[i], nonAccent);
      }
    });
    return result;
  }

  /// Tạo chuỗi key duy nhất = tên_không_dấu + ngày_sinh (ddmmyyyy)
  static String makeKey(String studentName, String dobDMY) {
    final name = stripAccents(studentName).replaceAll(RegExp(r'[^a-z0-9]'), '');
    final dob = dobDMY.replaceAll(RegExp(r'\D'), '');
    return name + dob;
  }

  /// FNV-1a 32-bit hash algorithm + trộn bit Avalanche
  /// Đảm bảo tính tất định 100% khớp với Javascript trong animal-card.html
  static int hashString(String s) {
    int h = 2166136261;
    for (int i = 0; i < s.length; i++) {
      h = (h ^ s.codeUnitAt(i)) & 0xFFFFFFFF;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    h = (h ^ (h >> 16)) & 0xFFFFFFFF;
    h = (h * 2246822507) & 0xFFFFFFFF;
    h = (h ^ (h >> 13)) & 0xFFFFFFFF;
    return h;
  }

  /// Trả về con vật định danh từ tên và ngày sinh
  static AnimalMascotModel pickAnimal({required String studentName, required String dobDMY}) {
    final key = makeKey(studentName, dobDMY);
    if (key.isEmpty) {
      return AnimalMascotData.allMascots[0];
    }
    final hash = hashString(key);
    final index = hash % AnimalMascotData.allMascots.length;
    return AnimalMascotData.allMascots[index];
  }
}
