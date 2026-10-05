import '../core/database/database_helper.dart';
import '../models/event.dart';

class EventRepository {
  final DatabaseHelper _dbHelper;

  EventRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> insert(Event e) async {
    final db = await _dbHelper.database;
    final map = e.toMap()..remove('id');
    return db.insert('events', map);
  }

  Future<int> update(Event e) async {
    final db = await _dbHelper.database;
    return db.update('events', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<Event?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('events', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Event.fromMap(rows.first);
  }

  Future<List<Event>> getByDateRange(DateTime from, DateTime to) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'events',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        from.toIso8601String().substring(0, 10),
        to.toIso8601String().substring(0, 10),
      ],
      orderBy: 'date ASC, start_time ASC',
    );
    return rows.map(Event.fromMap).toList();
  }

  Future<List<Event>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('events', orderBy: 'date ASC');
    return rows.map(Event.fromMap).toList();
  }

  Future<List<Event>> getRecurring() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'events',
      where: "repeat != 'none'",
      orderBy: 'date ASC',
    );
    return rows.map(Event.fromMap).toList();
  }
}
