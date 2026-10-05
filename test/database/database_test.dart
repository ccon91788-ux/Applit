import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:lifesync/models/transaction.dart';
import 'package:lifesync/models/event.dart';
import 'package:lifesync/models/savings_goal.dart';
import 'package:lifesync/models/budget.dart';
import 'package:lifesync/models/recurring_bill.dart';
import 'package:lifesync/repositories/transaction_repository.dart';
import 'package:lifesync/repositories/event_repository.dart';
import 'package:lifesync/repositories/goal_repository.dart';
import 'package:lifesync/repositories/budget_repository.dart';
import 'package:lifesync/repositories/recurring_bill_repository.dart';
import 'package:lifesync/core/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          // Minimal schema for tests
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
              updated_at TEXT NOT NULL
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
        },
      ),
    );
    await DatabaseHelper.resetForTest(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Create Read Update Delete transaction', () async {
    final repo = TransactionRepository();
    final now = DateTime.now();
    final id = await repo.insert(
      Transaction(
        type: 'expense',
        amount: 50000,
        category: 'Ăn uống',
        note: 'test',
        date: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(id, greaterThan(0));

    final t = await repo.getById(id);
    expect(t, isNotNull);
    expect(t!.amount, 50000);

    await repo.update(t.copyWith(amount: 60000, updatedAt: now));
    final t2 = await repo.getById(id);
    expect(t2!.amount, 60000);

    await repo.delete(id);
    expect(await repo.getById(id), isNull);
  });

  test('Create event', () async {
    final repo = EventRepository();
    final now = DateTime.now();
    final id = await repo.insert(
      Event(
        title: 'Study Physics',
        date: DateTime(2026, 10, 1),
        startTime: '19:00',
        repeat: 'weekly',
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(id, greaterThan(0));
    final e = await repo.getById(id);
    expect(e!.title, 'Study Physics');
    expect(e.repeat, 'weekly');
  });

  test('Create savings goal', () async {
    final repo = GoalRepository();
    final now = DateTime.now();
    final id = await repo.insert(
      SavingsGoal(
        name: 'Buy laptop',
        targetAmount: 10000000,
        currentAmount: 3000000,
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(id, greaterThan(0));
  });

  test('Create budget', () async {
    final repo = BudgetRepository();
    final now = DateTime.now();
    final id = await repo.upsert(
      Budget(
        year: 2026,
        month: 10,
        amount: 5000000,
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(id, greaterThan(0));
    final b = await repo.getByMonth(2026, 10);
    expect(b!.amount, 5000000);
  });

  test('Create recurring bill', () async {
    final repo = RecurringBillRepository();
    final now = DateTime.now();
    final id = await repo.insert(
      RecurringBill(
        name: 'Internet',
        amount: 300000,
        category: 'Hóa đơn',
        dueDay: 10,
        nextDueDate: DateTime(2026, 10, 10),
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(id, greaterThan(0));
  });
}
