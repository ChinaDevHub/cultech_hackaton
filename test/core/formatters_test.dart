import 'package:cultech_hackaton/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('thousands inserts separators', () {
      expect(Formatters.thousands(0), '0');
      expect(Formatters.thousands(999), '999');
      expect(Formatters.thousands(1240), '1,240');
      expect(Formatters.thousands(1234567), '1,234,567');
      expect(Formatters.thousands(-12400), '-12,400');
    });

    test('compactUsd matches dashboard copy', () {
      expect(Formatters.compactUsd(12400), r'$12.4K');
      expect(Formatters.compactUsd(12000), r'$12K');
      expect(Formatters.compactUsd(1250000), r'$1.3M');
      expect(Formatters.compactUsd(950), r'$950');
    });

    test('percent, clock and file size', () {
      expect(Formatters.percent(0.968), '96.8%');
      expect(Formatters.clock(DateTime(2026, 1, 1, 9, 5, 3)), '09:05:03');
      expect(Formatters.fileSize(512), '512 B');
      expect(Formatters.fileSize(2516582), '2.4 MB');
    });
  });
}
