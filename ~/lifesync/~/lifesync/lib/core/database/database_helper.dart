import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;
  static const int _version = 2;
  static const String _dbName = 'lifesync.db';

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'cash',
        balance INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        budget_limit INTEGER,
        color INTEGER,
        icon TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        time TEXT,
        wallet_id INTEGER,
        source TEXT,
        source_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES wallets(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        reminder TEXT,
        repeat TEXT NOT NULL DEFAULT 'none',
        notification_sound INTEGER NOT NULL DEFAULT 1,
        vibration INTEGER NOT NULL DEFAULT 1,
        color INTEGER,
        labels TEXT,
        note TEXT,
        repeat_end_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount INTEGER NOT NULL,
        current_amount INTEGER NOT NULL DEFAULT 0,
        deadline TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        alerts_enabled INTEGER NOT NULL DEFAULT 1,
        alert_80_triggered INTEGER NOT NULL DEFAULT 0,
        alert_90_triggered INTEGER NOT NULL DEFAULT 0,
        alert_100_triggered INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(year, month)
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        due_day INTEGER NOT NULL,
        note TEXT,
        enabled INTEGER NOT NULL DEFAULT 1,
        next_due_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL DEFAULT 'monthly',
        start_date TEXT NOT NULL,
        end_date TEXT,
        next_date TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        note TEXT,
        wallet_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Indexes for performance
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions(date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions(type)',
    );
    await db.execute('CREATE INDEX idx_events_date ON events(date)');
    await db.execute(
      'CREATE INDEX idx_recurring_bills_next ON recurring_bills(next_due_date)',
    );

    await _seedDefaults(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Future migrations can go here
    }
  }

  Future<void> _seedDefaults(Database db) async {
    final now = DateTime.now().toIso8601String();
    // Default wallet
    await db.insert('wallets', {
      'name': 'Tiền mặt',
      'type': 'cash',
      'balance': 0,
      'is_default': 1,
      'created_at': now,
      'updated_at': now,
    });

    final incomeCats = ['Lương', 'Trợ cấp', 'Kinh doanh', 'Thu nhập khác'];
    final expenseCats = [
      'Ăn uống',
      'Di chuyển',
      'Học tập',
      'Mua sắm',
      'Giải trí',
      'Hóa đơn',
      'Sức khỏe',
      'Chi tiêu khác',
    ];

    for (final c in incomeCats) {
      await db.insert('categories', {
        'name': c,
        'type': 'income',
        'is_default': 1,
        'created_at': now,
      });
    }
    for (final c in expenseCats) {
      await db.insert('categories', {
        'name': c,
        'type': 'expense',
        'is_default': 1,
        'created_at': now,
      });
    }
  }

  /// For tests: allow injecting a database.
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }

  /// Reset for testing only.
  static Future<void> resetForTest(Database db) async {
    _db = db;
  }
}
