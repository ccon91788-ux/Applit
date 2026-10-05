import 'dart:convert';
import 'package:intl/intl.dart';
import '../core/database/database_helper.dart';
import '../models/transaction.dart';
import '../models/event.dart';
import '../models/savings_goal.dart';
import '../models/budget.dart';
import '../models/recurring_bill.dart';
import '../models/wallet.dart';
import '../models/category.dart';
import '../models/recurring_income.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/recurring_bill_repository.dart';

class BackupService {
  static const int backupVersion = 1;

  final TransactionRepository _txRepo;
  final EventRepository _eventRepo;
  final GoalRepository _goalRepo;
  final RecurringBillRepository _billRepo;

  BackupService({
    TransactionRepository? txRepo,
    EventRepository? eventRepo,
    GoalRepository? goalRepo,
    RecurringBillRepository? billRepo,
  }) : _txRepo = txRepo ?? TransactionRepository(),
       _eventRepo = eventRepo ?? EventRepository(),
       _goalRepo = goalRepo ?? GoalRepository(),
       _billRepo = billRepo ?? RecurringBillRepository();

  Future<Map<String, dynamic>> exportAll() async {
    final db = await DatabaseHelper.instance.database;
    final wallets = (await db.query('wallets')).map(Wallet.fromMap).toList();
    final categories = (await db.query(
      'categories',
    )).map(Category.fromMap).toList();
    final txs = await _txRepo.getPaginated(limit: 100000);
    final events = await _eventRepo.getAll();
    final goals = await _goalRepo.getAll();
    final bills = await _billRepo.getAll();
    final incomes = (await db.query(
      'recurring_incomes',
    )).map(RecurringIncome.fromMap).toList();
    final budgets = (await db.query('budgets')).map(Budget.fromMap).toList();
    final settings = await db.query('settings');

    return {
      'version': backupVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'wallets': wallets.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'transactions': txs.map((e) => e.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'budgets': budgets.map((e) => e.toJson()).toList(),
      'recurring_bills': bills.map((e) => e.toJson()).toList(),
      'recurring_incomes': incomes.map((e) => e.toJson()).toList(),
      'settings': settings,
    };
  }

  String exportJson() {
    // Caller should await exportAll then encode
    return '';
  }

  Future<String> exportJsonString() async {
    final data = await exportAll();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String suggestedFilename() {
    final d = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return 'LifeSync_Backup_$d.json';
  }

  /// Validate and return error message or null if ok.
  String? validateBackup(Map<String, dynamic> data) {
    if (data['version'] == null) return 'Thiếu phiên bản sao lưu.';
    final v = data['version'];
    if (v is! int || v < 1 || v > backupVersion) {
      return 'Phiên bản sao lưu không được hỗ trợ.';
    }
    if (data['transactions'] != null && data['transactions'] is! List) {
      return 'Dữ liệu giao dịch không hợp lệ.';
    }
    return null;
  }

  Future<void> restore(
    Map<String, dynamic> data, {
    bool clearExisting = true,
  }) async {
    final err = validateBackup(data);
    if (err != null) throw FormatException(err);

    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      if (clearExisting) {
        await txn.delete('transactions');
        await txn.delete('events');
        await txn.delete('goals');
        await txn.delete('budgets');
        await txn.delete('recurring_bills');
        await txn.delete('recurring_incomes');
        // Keep default categories/wallets structure; optionally clear custom
      }

      if (data['transactions'] is List) {
        for (final item in data['transactions'] as List) {
          if (item is Map<String, dynamic>) {
            final t = Transaction.fromJson(item);
            final map = t.toMap()..remove('id');
            await txn.insert('transactions', map);
          }
        }
      }
      if (data['events'] is List) {
        for (final item in data['events'] as List) {
          if (item is Map<String, dynamic>) {
            final e = Event.fromJson(item);
            final map = e.toMap()..remove('id');
            await txn.insert('events', map);
          }
        }
      }
      if (data['goals'] is List) {
        for (final item in data['goals'] as List) {
          if (item is Map<String, dynamic>) {
            final g = SavingsGoal.fromJson(item);
            final map = g.toMap()..remove('id');
            await txn.insert('goals', map);
          }
        }
      }
      if (data['budgets'] is List) {
        for (final item in data['budgets'] as List) {
          if (item is Map<String, dynamic>) {
            final b = Budget.fromJson(item);
            final map = b.toMap()..remove('id');
            await txn.insert('budgets', map);
          }
        }
      }
      if (data['recurring_bills'] is List) {
        for (final item in data['recurring_bills'] as List) {
          if (item is Map<String, dynamic>) {
            final b = RecurringBill.fromJson(item);
            final map = b.toMap()..remove('id');
            await txn.insert('recurring_bills', map);
          }
        }
      }
    });
  }
}
