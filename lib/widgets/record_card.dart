import 'package:flutter/material.dart';

import '../models/work_record.dart';

class RecordCard extends StatelessWidget {
  final WorkRecord record;
  final double hourlyRate;
  final VoidCallback onLongPress;

  const RecordCard({
    super.key,
    required this.record,
    required this.hourlyRate,
    required this.onLongPress,
  });

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '周${_weekdays[record.date.weekday - 1]}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.date.month}月${record.date.day}日',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(record.startTimeStr,
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('→',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      Text(record.endTimeStr,
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.durationStr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  if (hourlyRate > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '¥${(record.hoursWorked * hourlyRate).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
