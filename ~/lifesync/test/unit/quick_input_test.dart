import 'package:flutter_test/flutter_test.dart';
import 'package:lifesync/services/quick_input_service.dart';

void main() {
  group('QuickInputService', () {
    test('Chi 50k ăn sáng => expense 50000', () {
      final r = QuickInputService.parse('Chi 50k ăn sáng');
      expect(r, isNotNull);
      expect(r!.type, 'expense');
      expect(r.amount, 50000);
    });

    test('Thu 8tr lương => income 8000000', () {
      final r = QuickInputService.parse('Thu 8tr lương');
      expect(r, isNotNull);
      expect(r!.type, 'income');
      expect(r.amount, 8000000);
    });

    test('Chi 35.000 tiền xăng', () {
      final r = QuickInputService.parse('Chi 35.000 tiền xăng');
      expect(r, isNotNull);
      expect(r!.type, 'expense');
      expect(r.amount, 35000);
    });

    test('Thu 500k', () {
      final r = QuickInputService.parse('Thu 500k');
      expect(r, isNotNull);
      expect(r!.type, 'income');
      expect(r.amount, 500000);
    });

    test('Chi 1 triệu mua sách', () {
      final r = QuickInputService.parse('Chi 1 triệu mua sách');
      expect(r, isNotNull);
      expect(r!.amount, 1000000);
    });
  });
}
