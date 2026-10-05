import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../services/lunar_service.dart';
import '../../models/event.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/app_theme.dart';
import 'event_form_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  String _view = 'month'; // month | week | day

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshCalendar(_focused);
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _focused = DateTime(_focused.year, _focused.month + delta, 1);
    });
    context.read<AppState>().refreshCalendar(_focused);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy', 'vi_VN').format(_focused)),
        actions: [
          IconButton(
            tooltip: 'Hôm nay',
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focused = DateTime.now();
                _selected = DateTime.now();
              });
              context.read<AppState>().refreshCalendar(_focused);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _view = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'month', child: Text('Tháng')),
              PopupMenuItem(value: 'week', child: Text('Tuần')),
              PopupMenuItem(value: 'day', child: Text('Ngày')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => EventFormSheet(initialDate: _selected),
          );
          if (created == true && mounted) {
            context.read<AppState>().refreshCalendar(_focused);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_view == 'month') _buildMonthGrid(state, theme),
          if (_view == 'week') _buildWeekView(state, theme),
          if (_view == 'day') _buildDayView(state, theme),
          const Divider(height: 1),
          Expanded(child: _buildEventList(state, theme)),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(AppState state, ThemeData theme) {
    final first = DateTime(_focused.year, _focused.month, 1);
    final daysInMonth = DateTime(_focused.year, _focused.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // 0=Sun

    final cells = <Widget>[];
    const labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    for (final l in labels) {
      cells.add(Center(child: Text(l, style: theme.textTheme.labelSmall)));
    }
    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_focused.year, _focused.month, d);
      final isSelected = AppDateUtils.isSameDay(date, _selected);
      final isToday = AppDateUtils.isSameDay(date, DateTime.now());
      final hasEvents = state.monthEvents.any(
        (e) => AppDateUtils.isSameDay(e.date, date),
      );
      final lunar = LunarService.formatLunar(date);

      cells.add(
        InkWell(
          onTap: () => setState(() => _selected = date),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : isToday
                  ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$d',
                  style: TextStyle(
                    fontWeight: isToday || isSelected ? FontWeight.bold : null,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : null,
                  ),
                ),
                if (lunar.isNotEmpty)
                  Text(
                    lunar.split(' ').first,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (hasEvents)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        children: cells,
      ),
    );
  }

  Widget _buildWeekView(AppState state, ThemeData theme) {
    final start = _selected.subtract(Duration(days: _selected.weekday % 7));
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (_, i) {
          final d = start.add(Duration(days: i));
          final selected = AppDateUtils.isSameDay(d, _selected);
          return InkWell(
            onTap: () => setState(() => _selected = d),
            child: Container(
              width: 56,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: selected ? theme.colorScheme.primaryContainer : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E', 'vi_VN').format(d)),
                  Text(
                    '${d.day}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayView(AppState state, ThemeData theme) {
    final lunar = LunarService.formatLunar(_selected);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selected),
            style: theme.textTheme.titleMedium,
          ),
          if (lunar.isNotEmpty)
            Text('Âm lịch: $lunar', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEventList(AppState state, ThemeData theme) {
    final events = state.monthEvents
        .where((e) => AppDateUtils.isSameDay(e.date, _selected))
        .toList();
    final dayBills = state.bills
        .where((b) => AppDateUtils.isSameDay(b.nextDueDate, _selected))
        .toList();

    if (events.isEmpty && dayBills.isEmpty) {
      return Center(
        child: Text(
          'Không có sự kiện ngày ${DateFormat('dd/MM').format(_selected)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...events.map((e) {
          final c = e.color != null ? Color(e.color!) : AppTheme.primary;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: c.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: c.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.event, color: Colors.white, size: 20),
              ),
              title: Text(
                e.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${e.startTime}${e.endTime != null ? ' - ${e.endTime}' : ''}'
                '${e.labels != null ? ' · ${e.labels}' : ''}',
              ),
              trailing: e.repeat != 'none'
                  ? const Icon(Icons.repeat, size: 18)
                  : null,
            ),
          );
        }),
        ...dayBills.map(
          (b) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.expenseColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.expenseColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                b.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Hóa đơn · ${b.amount} ₫'),
            ),
          ),
        ),
      ],
    );
  }
}
