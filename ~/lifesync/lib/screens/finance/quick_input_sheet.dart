import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/quick_input_service.dart';
import '../../models/transaction.dart';
import '../../providers/app_state.dart';
import '../../core/utils/money_formatter.dart';

class QuickInputSheet extends StatefulWidget {
  const QuickInputSheet({super.key});

  @override
  State<QuickInputSheet> createState() => _QuickInputSheetState();
}

class _QuickInputSheetState extends State<QuickInputSheet> {
  final _ctrl = TextEditingController();
  QuickInputResult? _preview;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _parse() {
    setState(() => _preview = QuickInputService.parse(_ctrl.text));
  }

  Future<void> _confirm() async {
    final p = _preview;
    if (p == null) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final t = Transaction(
        type: p.type,
        amount: p.amount,
        category:
            p.category ??
            (p.type == 'income' ? 'Thu nhập khác' : 'Chi tiêu khác'),
        note: p.note,
        date: now,
        createdAt: now,
        updatedAt: now,
      );
      await context.read<AppState>().txRepo.insert(t);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể lưu: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nhập nhanh', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Ví dụ: "Chi 50k ăn sáng", "Thu 8tr lương"',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Nhập nội dung',
              hintText: 'Chi 50k ăn sáng',
            ),
            onChanged: (_) => _parse(),
            autofocus: true,
          ),
          if (_preview != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _preview!.confident ? 'Đã nhận dạng:' : 'Cần xác nhận:',
                    ),
                    Text(
                      'Loại: ${_preview!.type == 'income' ? 'Thu nhập' : 'Chi tiêu'}',
                    ),
                    Text('Số tiền: ${MoneyFormatter.format(_preview!.amount)}'),
                    if (_preview!.category != null)
                      Text('Danh mục: ${_preview!.category}'),
                    if (_preview!.note != null)
                      Text('Ghi chú: ${_preview!.note}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _confirm,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Xác nhận lưu'),
            ),
          ],
        ],
      ),
    );
  }
}
