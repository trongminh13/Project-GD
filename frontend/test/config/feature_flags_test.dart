import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

void main() {
  group('FeatureFlags Tests', () {
    tearDown(() {
      FeatureFlags.reset();
    });

    test('FeatureFlags maintains boolean flag values correctly', () {
      expect(FeatureFlags.enableAutoSave, isTrue);
      expect(FeatureFlags.enableMaterials, isTrue);
      expect(FeatureFlags.enableTimetable, isTrue);
    });

    test('useDemoFallback toggle changes state dynamically at runtime', () {
      FeatureFlags.useDemoFallback = false;
      expect(FeatureFlags.useDemoFallback, isFalse);

      FeatureFlags.useDemoFallback = true;
      expect(FeatureFlags.useDemoFallback, isTrue);
    });

    test('reset restores initial default state', () {
      FeatureFlags.useDemoFallback = false;
      expect(FeatureFlags.useDemoFallback, isFalse);

      FeatureFlags.reset();
      // By default in flutter_test, kDebugMode is true
      expect(FeatureFlags.useDemoFallback, isTrue);
    });
  });
}
