import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/app_state.dart';
import '../../core/notifications/notification_service.dart';

class EventFormSheet extends StatefulWidget {
  final DateTime initialDate;
  final Event? existing;

  const EventFormSheet({super.key, required this.initialDate, this.existing});

  @override
  State<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<EventFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late DateTime _date;
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _end;
  String _repeat = 'none';
  String _reminder = '15m';
  bool _sound = true;
  bool _vibration = true;
  int? _color;
  final _labelsCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description ?? '';
      _noteCtrl.text = e.note ?? '';
      _date = e.date;
      final parts = e.startTime.split(':');
      _start = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      _repeat = e.repeat;
      _reminder = e.reminder ?? '15m';
      _sound = e.notificationSound;
      _vibration = e.vibration;
      _color = e.color;
      _labelsCtrl.text = e.labels ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _noteCtrl.dispose();
    _labelsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề sự kiện')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final startStr =
          '${_start.hour.toString().padLeft(2, '0')}:${_start.minute.toString().padLeft(2, '0')}';
      final event = Event(
        id: widget.existing?.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        date: _date,
        startTime: startStr,
        endTime: _end != null
            ? '${_end!.hour.toString().padLeft(2, '0')}:${_end!.minute.toString().padLeft(2, '0')}'
            : null,
        reminder: _reminder,
        repeat: _repeat,
        notificationSound: _sound,
        vibration: _vibration,
        color: _color,
        labels: _labelsCtrl.text.trim().isEmpty
            ? null
            : _labelsCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      final state = context.read<AppState>();
      if (widget.existing != null) {
        await state.eventRepo.update(event);
      } else {
        final id = await state.eventRepo.insert(event);
        // Schedule notification
        final scheduled = _computeReminderTime(_date, startStr, _reminder);
        if (scheduled != null) {
          await NotificationService.instance.scheduleEventReminder(
            id: id,
            title: event.title,
            body: event.description ?? 'Nhắc nhở sự kiện',
            scheduledAt: scheduled,
            sound: _sound,
            vibration: _vibration,
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể lưu sự kiện: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  DateTime? _computeReminderTime(DateTime date, String start, String reminder) {
    final parts = start.split(':');
    var at = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    switch (reminder) {
      case 'at_time':
        break;
      case '5m':
        at = at.subtract(const Duration(minutes: 5));
        break;
      case '10m':
        at = at.subtract(const Duration(minutes: 10));
        break;
      case '15m':
        at = at.subtract(const Duration(minutes: 15));
        break;
      case '30m':
        at = at.subtract(const Duration(minutes: 30));
        break;
      case '1h':
        at = at.subtract(const Duration(hours: 1));
        break;
      case '1d':
        at = at.subtract(const Duration(days: 1));
        break;
    }
    return at;
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Thêm sự kiện' : 'Sửa sự kiện',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Tiêu đề *'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Giờ bắt đầu'),
              subtitle: Text(_start.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _start,
                );
                if (t != null) setState(() => _start = t);
              },
            ),
            DropdownButtonFormField<String>(
              value: _repeat,
              decoration: const InputDecoration(labelText: 'Lặp lại'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Không lặp')),
                DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                DropdownMenuItem(value: 'monthly', child: Text('Hàng tháng')),
                DropdownMenuItem(value: 'yearly', child: Text('Hàng năm')),
              ],
              onChanged: (v) => setState(() => _repeat = v ?? 'none'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _reminder,
              decoration: const InputDecoration(labelText: 'Nhắc nhở'),
              items: const [
                DropdownMenuItem(value: 'at_time', child: Text('Đúng giờ')),
                DropdownMenuItem(value: '5m', child: Text('Trước 5 phút')),
                DropdownMenuItem(value: '10m', child: Text('Trước 10 phút')),
                DropdownMenuItem(value: '15m', child: Text('Trước 15 phút')),
                DropdownMenuItem(value: '30m', child: Text('Trước 30 phút')),
                DropdownMenuItem(value: '1h', child: Text('Trước 1 giờ')),
                DropdownMenuItem(value: '1d', child: Text('Trước 1 ngày')),
              ],
              onChanged: (v) => setState(() => _reminder = v ?? '15m'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelsCtrl,
              decoration: const InputDecoration(
                labelText: 'Nhãn / Tags',
                hintText: 'công việc, cá nhân',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
              maxLines: 2,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Âm thanh'),
              value: _sound,
              onChanged: (v) => setState(() => _sound = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rung'),
              value: _vibration,
              onChanged: (v) => setState(() => _vibration = v),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
