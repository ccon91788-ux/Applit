import 'package:sqflite/sqflite.dart' hide Transaction;
import '../core/database/database_helper.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> insert(Transaction t) async {
    final db = await _dbHelper.database;
    final map = t.toMap()..remove('id');
    return db.insert('transactions', map);
  }

  Future<int> update(Transaction t) async {
    final db = await _dbHelper.database;
    return db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Transaction?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Transaction.fromMap(rows.first);
  }

  /// Paginated query with optional filters. Filtering done in SQL.
  Future<List<Transaction>> getPaginated({
    int limit = 50,
    int offset = 0,
    String? type,
    DateTime? from,
    DateTime? to,
    String? category,
    int? walletId,
    String? search,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String().substring(0, 10));
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(to.toIso8601String().substring(0, 10));
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    if (walletId != null) {
      where.add('wallet_id = ?');
      args.add(walletId);
    }
    if (search != null && search.isNotEmpty) {
      where.add('(note LIKE ? OR category LIKE ?)');
      args.add('%$search%');
      args.add('%$search%');
    }

    final rows = await db.query(
      'transactions',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<int> sumByType({
    required String type,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>['type = ?'];
    final args = <dynamic>[type];
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String().substring(0, 10));
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(to.toIso8601String().substring(0, 10));
    }
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE ${where.join(' AND ')}',
      args,
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<Map<String, int>> sumByCategory({
    required String type,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>['type = ?'];
    final args = <dynamic>[type];
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String().substring(0, 10));
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(to.toIso8601String().substring(0, 10));
    }
    final rows = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE ${where.join(' AND ')} GROUP BY category',
      args,
    );
    return {
      for (final r in rows) r['category'] as String: r['total'] as int? ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> monthlyTrend({required int months}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final from = DateTime(now.year, now.month - months + 1, 1);
    final rows = await db.rawQuery(
      '''
      SELECT substr(date, 1, 7) as ym,
             SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as income,
             SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as expense
      FROM transactions
      WHERE date >= ?
      GROUP BY ym
      ORDER BY ym
    ''',
      [from.toIso8601String().substring(0, 10)],
    );
    return rows;
  }

  Future<bool> existsSource(String source, int sourceId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'transactions',
      where: 'source = ? AND source_id = ?',
      whereArgs: [source, sourceId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
