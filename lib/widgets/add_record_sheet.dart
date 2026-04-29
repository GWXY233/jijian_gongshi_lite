import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/work_record.dart';
import '../providers/records_provider.dart';
import '../providers/settings_provider.dart';

class AddRecordSheet extends ConsumerStatefulWidget {
  const AddRecordSheet({super.key});

  @override
  ConsumerState<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends ConsumerState<AddRecordSheet> {
  DateTime _date = DateTime.now();
  int _startMinutes = 9 * 60;
  int _endMinutes = 18 * 60;

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  bool get _isValid => _endMinutes > _startMinutes;

  double get _hours => (_endMinutes - _startMinutes) / 60.0;

  String get _preview {
    if (!_isValid) return '下班时间必须晚于上班时间';
    final rate = ref.read(settingsProvider).valueOrNull?.hourlyRate ?? 0.0;
    if (rate > 0) {
      return '${_hours.toStringAsFixed(1)}小时 · ¥${(_hours * rate).toStringAsFixed(2)}';
    }
    return '${_hours.toStringAsFixed(1)}小时';
  }

  void _save() {
    final record = WorkRecord.create(
      date: DateTime(_date.year, _date.month, _date.day),
      startMinutes: _startMinutes,
      endMinutes: _endMinutes,
    );
    ref.read(recordsProvider.notifier).addRecord(record);
    Navigator.pop(context);
  }

  Widget _buildRow(String label, String value, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 15)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF6C63FF))),
          ],
        ),
      ),
    );
  }

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('记录工时',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 16),
            _buildRow(
              '日期',
              '${_date.month}月${_date.day}日 周${_weekdays[_date.weekday - 1]}',
              () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020, 1, 1),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const Divider(height: 1, indent: 20),
            _buildRow('上班', _fmt(_startMinutes), () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                    hour: _startMinutes ~/ 60, minute: _startMinutes % 60),
              );
              if (picked != null) {
                setState(
                    () => _startMinutes = picked.hour * 60 + picked.minute);
              }
            }),
            const Divider(height: 1, indent: 20),
            _buildRow('下班', _fmt(_endMinutes), () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                    hour: _endMinutes ~/ 60, minute: _endMinutes % 60),
              );
              if (picked != null) {
                setState(
                    () => _endMinutes = picked.hour * 60 + picked.minute);
              }
            }),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _preview,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _isValid
                      ? const Color(0xFF6C63FF)
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  onPressed: _isValid ? _save : null,
                  child: const Text('保存',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
