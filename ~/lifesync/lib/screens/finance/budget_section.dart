import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/budget.dart';
import '../../core/notifications/notification_service.dart';
import '../../widgets/common/gradient_card.dart';

class BudgetSection extends StatelessWidget {
  const BudgetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final budget = state.currentBudget;
    final spent = state.totalExpense;
    final theme = Theme.of(context);

    return GradientCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.accentOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ngân sách tháng',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _editBudget(context, state),
                child: Text(
                  budget == null ? 'Thiết lập' : 'Sửa',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (budget == null) ...[
            const SizedBox(height: 12),
            Text(
              'Chưa đặt ngân sách tháng này',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat(
                  'Ngân sách',
                  MoneyFormatter.format(budget.amount),
                  AppTheme.primary,
                ),
                _miniStat(
                  'Đã chi',
                  MoneyFormatter.format(spent),
                  AppTheme.expenseColor,
                ),
                _miniStat(
                  'Còn lại',
                  MoneyFormatter.format(
                    (budget.amount - spent).clamp(0, budget.amount),
                  ),
                  AppTheme.incomeColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: budget.amount > 0
                    ? (spent / budget.amount).clamp(0.0, 1.0)
                    : 0,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  spent / budget.amount >= 1
                      ? AppTheme.expenseColor
                      : spent / budget.amount >= 0.8
                      ? AppTheme.accentOrange
                      : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${budget.amount > 0 ? ((spent / budget.amount) * 100).toStringAsFixed(0) : 0}% đã dùng',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _editBudget(BuildContext context, AppState state) async {
    final ctrl = TextEditingController(
      text: state.currentBudget != null
          ? MoneyFormatter.formatNumber(state.currentBudget!.amount)
          : '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ngân sách tháng'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Số tiền',
            suffixText: '₫',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final amount = MoneyFormatter.parse(ctrl.text);
      if (amount == null || amount <= 0) return;
      final now = DateTime.now();
      final b = Budget(
        year: now.year,
        month: now.month,
        amount: amount,
        createdAt: state.currentBudget?.createdAt ?? now,
        updatedAt: now,
      );
      await state.budgetRepo.upsert(b);
      await state.refreshFinance();
      final spent = state.totalExpense;
      final pct = amount > 0 ? spent / amount : 0.0;
      var updated = await state.budgetRepo.getByMonth(now.year, now.month);
      if (updated != null && updated.alertsEnabled) {
        if (pct >= 1.0 && !updated.alert100Triggered) {
          await NotificationService.instance.showBudgetAlert(
            id: updated.id ?? 0,
            title: 'Vượt ngân sách',
            body: 'Bạn đã dùng 100% ngân sách tháng này.',
          );
          updated = updated.copyWith(alert100Triggered: true);
          await state.budgetRepo.updateAlerts(updated);
        } else if (pct >= 0.9 && !updated.alert90Triggered) {
          await NotificationService.instance.showBudgetAlert(
            id: updated.id ?? 0,
            title: 'Cảnh báo ngân sách',
            body: 'Bạn đã dùng 90% ngân sách tháng này.',
          );
          updated = updated.copyWith(alert90Triggered: true);
          await state.budgetRepo.updateAlerts(updated);
        } else if (pct >= 0.8 && !updated.alert80Triggered) {
          await NotificationService.instance.showBudgetAlert(
            id: updated.id ?? 0,
            title: 'Cảnh báo ngân sách',
            body: 'Bạn đã dùng 80% ngân sách tháng này.',
          );
          updated = updated.copyWith(alert80Triggered: true);
          await state.budgetRepo.updateAlerts(updated);
        }
      }
    }
  }
}
