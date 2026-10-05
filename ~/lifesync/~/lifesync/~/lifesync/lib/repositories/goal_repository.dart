import '../core/database/database_helper.dart';
import '../models/savings_goal.dart';

class GoalRepository {
  final DatabaseHelper _dbHelper;

  GoalRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> insert(SavingsGoal g) async {
    final db = await _dbHelper.database;
    final map = g.toMap()..remove('id');
    return db.insert('goals', map);
  }

  Future<int> update(SavingsGoal g) async {
    final db = await _dbHelper.database;
    return db.update('goals', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SavingsGoal>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('goals', orderBy: 'created_at DESC');
    return rows.map(SavingsGoal.fromMap).toList();
  }

  Future<SavingsGoal?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('goals', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return SavingsGoal.fromMap(rows.first);
  }
}
