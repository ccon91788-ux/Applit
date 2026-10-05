import '../core/database/database_helper.dart';
import '../models/budget.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper;

  BudgetRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> upsert(Budget b) async {
    final db = await _dbHelper.database;
    final existing = await getByMonth(b.year, b.month);
    if (existing != null) {
      final updated = b.copyWith(id: existing.id);
      await db.update(
        'budgets',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return existing.id!;
    }
    final map = b.toMap()..remove('id');
    return db.insert('budgets', map);
  }

  Future<Budget?> getByMonth(int year, int month) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );
    if (rows.isEmpty) return null;
    return Budget.fromMap(rows.first);
  }

  Future<int> updateAlerts(Budget b) async {
    final db = await _dbHelper.database;
    return db.update(
      'budgets',
      {
        'alert_80_triggered': b.alert80Triggered ? 1 : 0,
        'alert_90_triggered': b.alert90Triggered ? 1 : 0,
        'alert_100_triggered': b.alert100Triggered ? 1 : 0,
        'alerts_enabled': b.alertsEnabled ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [b.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
