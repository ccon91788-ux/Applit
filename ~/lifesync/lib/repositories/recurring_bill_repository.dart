import '../core/database/database_helper.dart';
import '../models/recurring_bill.dart';

class RecurringBillRepository {
  final DatabaseHelper _dbHelper;

  RecurringBillRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> insert(RecurringBill b) async {
    final db = await _dbHelper.database;
    final map = b.toMap()..remove('id');
    return db.insert('recurring_bills', map);
  }

  Future<int> update(RecurringBill b) async {
    final db = await _dbHelper.database;
    return db.update(
      'recurring_bills',
      b.toMap(),
      where: 'id = ?',
      whereArgs: [b.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('recurring_bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecurringBill>> getAll({bool enabledOnly = false}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'recurring_bills',
      where: enabledOnly ? 'enabled = 1' : null,
      orderBy: 'next_due_date ASC',
    );
    return rows.map(RecurringBill.fromMap).toList();
  }

  Future<RecurringBill?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'recurring_bills',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return RecurringBill.fromMap(rows.first);
  }
}
