import 'package:flutter/foundation.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/recurring_bill_repository.dart';
import '../models/transaction.dart';
import '../models/event.dart';
import '../models/savings_goal.dart';
import '../models/budget.dart';
import '../models/recurring_bill.dart';

/// Lightweight app state — targeted refreshes per feature.
class AppState extends ChangeNotifier {
  final TransactionRepository txRepo = TransactionRepository();
  final EventRepository eventRepo = EventRepository();
  final GoalRepository goalRepo = GoalRepository();
  final BudgetRepository budgetRepo = BudgetRepository();
  final RecurringBillRepository billRepo = RecurringBillRepository();

  List<Transaction> recentTransactions = [];
  List<Event> monthEvents = [];
  List<SavingsGoal> goals = [];
  Budget? currentBudget;
  List<RecurringBill> bills = [];
  int totalIncome = 0;
  int totalExpense = 0;
  bool loading = false;

  Future<void> refreshFinance({DateTime? from, DateTime? to}) async {
    loading = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final start = from ?? DateTime(now.year, now.month, 1);
      final end = to ?? DateTime(now.year, now.month + 1, 0);
      recentTransactions = await txRepo.getPaginated(
        limit: 50,
        from: start,
        to: end,
      );
      totalIncome = await txRepo.sumByType(
        type: 'income',
        from: start,
        to: end,
      );
      totalExpense = await txRepo.sumByType(
        type: 'expense',
        from: start,
        to: end,
      );
      currentBudget = await budgetRepo.getByMonth(now.year, now.month);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCalendar(DateTime month) async {
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0);
    monthEvents = await eventRepo.getByDateRange(from, to);
    bills = await billRepo.getAll(enabledOnly: true);
    notifyListeners();
  }

  Future<void> refreshGoals() async {
    goals = await goalRepo.getAll();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction t) async {
    await txRepo.insert(t);
    await refreshFinance();
  }

  Future<void> addEvent(Event e) async {
    await eventRepo.insert(e);
  }

  Future<void> refreshAll() async {
    await refreshFinance();
    await refreshCalendar(DateTime.now());
    await refreshGoals();
  }
}
