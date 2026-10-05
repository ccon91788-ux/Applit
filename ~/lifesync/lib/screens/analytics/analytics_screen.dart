import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../providers/app_state.dart';
import '../../core/utils/money_formatter.dart';
import '../../services/backup_service.dart';
import '../../services/csv_service.dart';

class AnalyticsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const AnalyticsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _range = 'this_month';
  Map<String, int> _byCategory = {};
  List<Map<String, dynamic>> _trend = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCharts());
  }

  Future<void> _loadCharts() async {
    final state = context.read<AppState>();
    final now = DateTime.now();
    DateTime from;
    DateTime to = DateTime(now.year, now.month + 1, 0);
    switch (_range) {
      case 'prev_month':
        from = DateTime(now.year, now.month - 1, 1);
        to = DateTime(now.year, now.month, 0);
        break;
      case 'last_3':
        from = DateTime(now.year, now.month - 2, 1);
        break;
      case 'last_6':
        from = DateTime(now.year, now.month - 5, 1);
        break;
      case 'this_year':
        from = DateTime(now.year, 1, 1);
        break;
      default:
        from = DateTime(now.year, now.month, 1);
    }
    final cats = await state.txRepo.sumByCategory(
      type: 'expense',
      from: from,
      to: to,
    );
    final trend = await state.txRepo.monthlyTrend(months: 6);
    setState(() {
      _byCategory = cats;
      _trend = trend;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích & Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan tháng này',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Thu: ${MoneyFormatter.format(state.totalIncome)}'),
                  Text('Chi: ${MoneyFormatter.format(state.totalExpense)}'),
                  Text(
                    'Số dư: ${MoneyFormatter.format(state.totalIncome - state.totalExpense)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Range filter
          DropdownButtonFormField<String>(
            value: _range,
            decoration: const InputDecoration(labelText: 'Khoảng thời gian'),
            items: const [
              DropdownMenuItem(value: 'this_month', child: Text('Tháng này')),
              DropdownMenuItem(value: 'prev_month', child: Text('Tháng trước')),
              DropdownMenuItem(
                value: 'last_3',
                child: Text('3 tháng gần nhất'),
              ),
              DropdownMenuItem(
                value: 'last_6',
                child: Text('6 tháng gần nhất'),
              ),
              DropdownMenuItem(value: 'this_year', child: Text('Năm nay')),
            ],
            onChanged: (v) {
              setState(() => _range = v ?? 'this_month');
              _loadCharts();
            },
          ),
          const SizedBox(height: 16),
          Text('Chi tiêu theo danh mục', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: _byCategory.isEmpty
                ? const Center(child: Text('Chưa có dữ liệu'))
                : PieChart(
                    PieChartData(
                      sections: _byCategory.entries.map((e) {
                        final total = _byCategory.values.fold(
                          0,
                          (a, b) => a + b,
                        );
                        final pct = total > 0 ? e.value / total : 0.0;
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          title: '${(pct * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
          ),
          if (_byCategory.isNotEmpty)
            ..._byCategory.entries.map(
              (e) => ListTile(
                dense: true,
                title: Text(e.key),
                trailing: Text(MoneyFormatter.format(e.value)),
              ),
            ),
          const SizedBox(height: 16),
          Text('Xu hướng thu/chi', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: _trend.isEmpty
                ? const Center(child: Text('Chưa có dữ liệu'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: [
                        for (var i = 0; i < _trend.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: ((_trend[i]['income'] as int?) ?? 0)
                                    .toDouble(),
                                color: Colors.green,
                                width: 8,
                              ),
                              BarChartRodData(
                                toY: ((_trend[i]['expense'] as int?) ?? 0)
                                    .toDouble(),
                                color: Colors.red,
                                width: 8,
                              ),
                            ],
                          ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= _trend.length)
                                return const SizedBox();
                              final ym = _trend[i]['ym'] as String? ?? '';
                              return Text(
                                ym.length >= 7 ? ym.substring(5) : ym,
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
          ),
          const Divider(height: 32),
          Text('Cài đặt', style: theme.textTheme.titleMedium),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Giao diện'),
            subtitle: Text(switch (widget.themeMode) {
              ThemeMode.light => 'Sáng',
              ThemeMode.dark => 'Tối',
              _ => 'Theo hệ thống',
            }),
            onTap: () {
              final next = switch (widget.themeMode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              };
              widget.onThemeChanged(next);
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Sao lưu dữ liệu'),
            onTap: () => _exportBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Khôi phục dữ liệu'),
            onTap: () => _importBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Xuất CSV giao dịch'),
            onTap: () => _exportCsv(context),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'LifeSync v1.0.0 · Offline-first',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final svc = BackupService();
      final json = await svc.exportJsonString();
      final name = svc.suggestedFilename();
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/$name');
      await file.writeAsString(json, encoding: utf8);
      await Share.shareXFiles([XFile(file.path)], text: 'LifeSync Backup');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể sao lưu: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;
      final content = await File(path).readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final svc = BackupService();
      final err = svc.validateBackup(data);
      if (err != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể nhập dữ liệu. $err')),
          );
        }
        return;
      }
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Khôi phục dữ liệu?'),
          content: const Text('Dữ liệu hiện tại có thể bị ghi đè. Tiếp tục?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Khôi phục'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await svc.restore(data);
      if (context.mounted) {
        await context.read<AppState>().refreshAll();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Khôi phục thành công')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể nhập dữ liệu. Tệp sao lưu không hợp lệ.'),
          ),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final state = context.read<AppState>();
      final txs = await state.txRepo.getPaginated(limit: 10000);
      final csv = CsvService.transactionsToCsv(txs);
      final name = CsvService.suggestedFilename();
      final file = File('${Directory.systemTemp.path}/$name');
      await file.writeAsString(csv, encoding: utf8);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'LifeSync Transactions');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể xuất CSV: $e')));
      }
    }
  }
}
