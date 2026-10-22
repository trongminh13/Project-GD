import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Đổi 'your_app' thành tên package trong pubspec.yaml của dự án.
import 'package:your_app/core/intro/intro_policy.dart';

void main() {
  late DateTime now;
  late SharedPrefsIntroPolicy policy;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    now = DateTime(2026, 10, 22, 8, 0);
    policy = SharedPrefsIntroPolicy(now: () => now);
  });

  test('lần đầu cài thì hiện', () async {
    expect(await policy.shouldShow(), isTrue);
  });

  test('trong 6 giờ sau lần hiện thì không hiện', () async {
    await policy.markShown();
    now = now.add(const Duration(hours: 5, minutes: 59));
    expect(await policy.shouldShow(), isFalse);
  });

  test('đủ 6 giờ thì hiện lại', () async {
    await policy.markShown();
    now = now.add(const Duration(hours: 6));
    expect(await policy.shouldShow(), isTrue);
  });

  test('người dùng tắt trong Cài đặt thì không bao giờ hiện', () async {
    await policy.setEnabled(false);
    expect(await policy.isEnabled(), isFalse);
    expect(await policy.shouldShow(), isFalse);

    now = now.add(const Duration(days: 30));
    expect(await policy.shouldShow(), isFalse);

    await policy.setEnabled(true);
    expect(await policy.shouldShow(), isTrue);
  });

  test('đồng hồ bị chỉnh lùi thì coi như hiện', () async {
    await policy.markShown();
    now = now.subtract(const Duration(hours: 2));
    expect(await policy.shouldShow(), isTrue);
  });
}
