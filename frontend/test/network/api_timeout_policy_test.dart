import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/core/services/fee_service.dart';

void main() {
  group('ApiTimeoutPolicy & Network Guard Tests', () {
    test('TC-TIMEOUT-01: ApiTimeoutPolicy defines correct tiered durations', () {
      expect(ApiTimeoutPolicy.fastRead.duration, equals(const Duration(seconds: 8)));
      expect(ApiTimeoutPolicy.mutation.duration, equals(const Duration(seconds: 15)));
      expect(ApiTimeoutPolicy.upload.duration, equals(const Duration(seconds: 60)));
      expect(ApiTimeoutPolicy.transactional.duration, equals(const Duration(seconds: 30)));
    });

    test('TC-IDEM-01: FeeService.generateIdempotencyKey produces valid RFC4122 v4 UUID', () {
      final key1 = FeeService.generateIdempotencyKey();
      final key2 = FeeService.generateIdempotencyKey();

      expect(key1, isNotEmpty);
      expect(key2, isNotEmpty);
      expect(key1, isNot(equals(key2)));

      // Regex chuẩn RFC4122 v4 UUID: xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx
      final uuidV4Regex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );

      expect(uuidV4Regex.hasMatch(key1), isTrue, reason: 'Key $key1 must match UUIDv4 format');
      expect(uuidV4Regex.hasMatch(key2), isTrue, reason: 'Key $key2 must match UUIDv4 format');
    });

    test('TC-IDEM-02: FeeService keys are 36 characters with 4 dashes', () {
      final key = FeeService.generateIdempotencyKey();
      expect(key.length, equals(36));
      expect(key.split('-').length, equals(5));
      expect(key.split('-')[0].length, equals(8));
      expect(key.split('-')[1].length, equals(4));
      expect(key.split('-')[2].length, equals(4));
      expect(key.split('-')[3].length, equals(4));
      expect(key.split('-')[4].length, equals(12));
    });
  });
}
