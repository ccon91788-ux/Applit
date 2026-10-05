import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/app_state.dart';
import '../../core/utils/money_formatter.dart';

class TransactionFormSheet extends StatefulWidget {
  final Transaction? existing;
  const TransactionFormSheet({super.key, this.existing});

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _type = 'expense';
  String _category = 'Ăn uống';
  DateTime _date = DateTime.now();
  bool _saving = false;

  static const _incomeCats = [
    'Lương',
    'Trợ cấp',
    'Kinh doanh',
    'Thu nhập khác',
  ];
  static const _expenseCats = [
    'Ăn uống',
    'Di chuyển',
    'Học tập',
    'Mua sắm',
    'Giải trí',
    'Hóa đơn',
    'Sức khỏe',
    'Chi tiêu khác',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _category = e.category;
      _amountCtrl.text = MoneyFormatter.formatNumber(e.amount);
      _noteCtrl.text = e.note ?? '';
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = MoneyFormatter.parse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền không hợp lệ')));
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final t = Transaction(
        id: widget.existing?.id,
        type: _type,
        amount: amount,
        category: _category,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        date: _date,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );
      final state = context.read<AppState>();
      if (widget.existing != null) {
        await state.txRepo.update(t);
      } else {
        await state.txRepo.insert(t);
      }
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
    final cats = _type == 'income' ? _incomeCats : _expenseCats;
    if (!cats.contains(_category)) _category = cats.first;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Thêm giao dịch' : 'Sửa giao dịch',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Chi'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Thu'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category =
                    (_type == 'income' ? _incomeCats : _expenseCats).first;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Số tiền *',
                suffixText: '₫',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items: cats
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? cats.first),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
              maxLines: 2,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ngày'),
              subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu'),
            ),
            if (widget.existing != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xóa giao dịch?'),
                      content: const Text('Thao tác này không thể hoàn tác.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Xóa'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && mounted) {
                    await context.read<AppState>().txRepo.delete(
                      widget.existing!.id!,
                    );
                    if (mounted) Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Xóa giao dịch',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
