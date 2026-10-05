import 'package:flutter_test/flutter_test.dart';
import 'package:lifesync/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter', () {
    test('format', () {
      final f50 = MoneyFormatter.format(50000);
      final f15 = MoneyFormatter.format(1500000);
      expect(f50.contains('50'), isTrue);
      expect(f50.contains('000'), isTrue);
      expect(f15.contains('1'), isTrue);
      expect(f15.contains('500'), isTrue);
      expect(f50.contains('₫'), isTrue);
    });

    test('parse variants', () {
      expect(MoneyFormatter.parse('50k'), 50000);
      expect(MoneyFormatter.parse('50K'), 50000);
      expect(MoneyFormatter.parse('1tr'), 1000000);
      expect(MoneyFormatter.parse('8 triệu'), 8000000);
      expect(MoneyFormatter.parse('1.5tr'), 1500000);
      expect(MoneyFormatter.parse('50.000'), 50000);
      expect(MoneyFormatter.parse('50,000'), 50000);
    });
  });
}
