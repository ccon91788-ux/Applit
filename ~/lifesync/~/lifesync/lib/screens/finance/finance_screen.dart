import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction.dart';
import '../../widgets/common/gradient_card.dart';
import 'transaction_form_sheet.dart';
import 'quick_input_sheet.dart';
import 'goals_section.dart';
import 'budget_section.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _scrollCtrl = ScrollController();
  int _offset = 0;
  static const _pageSize = 30;
  List<Transaction> _items = [];
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshFinance();
      _loadPage(reset: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadPage();
    }
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      if (reset) {
        _offset = 0;
        _hasMore = true;
      }
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, 1);
      final to = DateTime(now.year, now.month + 1, 0);
      final page = await context.read<AppState>().txRepo.getPaginated(
        limit: _pageSize,
        offset: _offset,
        from: from,
        to: to,
      );
      setState(() {
        if (reset) {
          _items = page;
        } else {
          _items.addAll(page);
        }
        _offset += page.length;
        _hasMore = page.length >= _pageSize;
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final balance = state.totalIncome - state.totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài chính'),
        actions: [
          IconButton(
            tooltip: 'Nhập nhanh',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
            ),
            onPressed: () async {
              final ok = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const QuickInputSheet(),
              );
              if (ok == true && mounted) {
                await context.read<AppState>().refreshFinance();
                _loadPage(reset: true);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const TransactionFormSheet(),
          );
          if (ok == true && mounted) {
            await context.read<AppState>().refreshFinance();
            _loadPage(reset: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          await context.read<AppState>().refreshFinance();
          await _loadPage(reset: true);
        },
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // Hero gradient summary cards
            Row(
              children: [
                Expanded(
                  child: MoneySummaryCard(
                    label: 'Thu nhập',
                    value: MoneyFormatter.format(state.totalIncome),
                    gradient: AppTheme.incomeGradient,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MoneySummaryCard(
                    label: 'Chi tiêu',
                    value: MoneyFormatter.format(state.totalExpense),
                    gradient: AppTheme.expenseGradient,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MoneySummaryCard(
              label: 'Số dư tháng này',
              value: MoneyFormatter.format(balance),
              gradient: AppTheme.balanceGradient,
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 20),

            // Quick action color tiles (illustration-grid style)
            Text(
              'Thao tác nhanh',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ColorTile(
                  icon: Icons.add_circle_outline,
                  label: 'Thu',
                  color: AppTheme.accentGreen,
                  onTap: () async {
                    final ok = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const TransactionFormSheet(),
                    );
                    if (ok == true && mounted) {
                      await context.read<AppState>().refreshFinance();
                      _loadPage(reset: true);
                    }
                  },
                ),
                ColorTile(
                  icon: Icons.remove_circle_outline,
                  label: 'Chi',
                  color: AppTheme.secondary,
                  onTap: () async {
                    final ok = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const TransactionFormSheet(),
                    );
                    if (ok == true && mounted) {
                      await context.read<AppState>().refreshFinance();
                      _loadPage(reset: true);
                    }
                  },
                ),
                ColorTile(
                  icon: Icons.flash_on,
                  label: 'Nhanh',
                  color: AppTheme.accentOrange,
                  onTap: () async {
                    final ok = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const QuickInputSheet(),
                    );
                    if (ok == true && mounted) {
                      await context.read<AppState>().refreshFinance();
                      _loadPage(reset: true);
                    }
                  },
                ),
                ColorTile(
                  icon: Icons.savings_outlined,
                  label: 'Tiết kiệm',
                  color: AppTheme.accentPurple,
                  onTap: () {
                    // scroll is handled by goals section below
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            const BudgetSection(),
            const SizedBox(height: 12),
            const GoalsSection(),
            const SizedBox(height: 20),

            Text(
              'Giao dịch gần đây',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            if (_items.isEmpty && !_loadingMore)
              GradientCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có giao dịch nào',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ..._items.map((t) {
              final isIncome = t.type == 'income';
              final color = isIncome
                  ? AppTheme.incomeColor
                  : AppTheme.expenseColor;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GradientCard(
                  onTap: () async {
                    final ok = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => TransactionFormSheet(existing: t),
                    );
                    if (ok == true && mounted) {
                      await context.read<AppState>().refreshFinance();
                      _loadPage(reset: true);
                    }
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (t.note != null && t.note!.isNotEmpty)
                                  t.note!,
                                '${t.date.day}/${t.date.month}/${t.date.year}',
                              ].join(' · '),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'}${MoneyFormatter.format(t.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_loadingMore)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
