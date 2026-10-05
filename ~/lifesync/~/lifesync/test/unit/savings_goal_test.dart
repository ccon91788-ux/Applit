import 'package:flutter_test/flutter_test.dart';
import 'package:lifesync/models/savings_goal.dart';

void main() {
  test('progress 0%', () {
    final g = SavingsGoal(
      name: 'Test',
      targetAmount: 10000000,
      currentAmount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(g.progress, 0);
  });

  test('progress 30%', () {
    final g = SavingsGoal(
      name: 'Test',
      targetAmount: 10000000,
      currentAmount: 3000000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(g.progress, closeTo(0.3, 0.001));
  });

  test('progress 100%', () {
    final g = SavingsGoal(
      name: 'Test',
      targetAmount: 10000000,
      currentAmount: 10000000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(g.progress, 1.0);
  });
}
