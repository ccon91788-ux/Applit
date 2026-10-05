import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/savings_goal.dart';
import '../../widgets/common/gradient_card.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
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
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppTheme.accentPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mục tiêu tiết kiệm',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _addGoal(context, state),
                child: const Text(
                  'Thêm',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (state.goals.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Chưa có mục tiêu nào',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else
            ...state.goals.map((g) {
              final colors = AppTheme.tileColors;
              final color = colors[g.id != null ? g.id! % colors.length : 0];
              return Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            g.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${MoneyFormatter.format(g.currentAmount)} / ${MoneyFormatter.format(g.targetAmount)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: g.progress,
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(g.progress * 100).toStringAsFixed(0)}% · Còn ${MoneyFormatter.format(g.remaining)}',
                      style: theme.textTheme.labelSmall,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _addMoney(context, state, g),
                          child: const Text('Thêm tiền'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await state.goalRepo.delete(g.id!);
                            await state.refreshGoals();
                          },
                          child: const Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _addGoal(BuildContext context, AppState state) async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mục tiêu mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Số tiền mục tiêu',
                suffixText: '₫',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
            ),
          ],
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
      final amount = MoneyFormatter.parse(amountCtrl.text);
      if (amount == null || amount <= 0 || nameCtrl.text.trim().isEmpty) return;
      final now = DateTime.now();
      await state.goalRepo.insert(
        SavingsGoal(
          name: nameCtrl.text.trim(),
          targetAmount: amount,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await state.refreshGoals();
    }
  }

  Future<void> _addMoney(
    BuildContext context,
    AppState state,
    SavingsGoal g,
  ) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm vào "${g.name}"'),
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
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final amount = MoneyFormatter.parse(ctrl.text);
      if (amount == null || amount <= 0) return;
      final updated = g.copyWith(
        currentAmount: g.currentAmount + amount,
        updatedAt: DateTime.now(),
      );
      await state.goalRepo.update(updated);
      await state.refreshGoals();
    }
  }
}
