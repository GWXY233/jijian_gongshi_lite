import 'package:flutter/material.dart';

import '../models/work_record.dart';

class WorkHeatmap extends StatelessWidget {
  final List<WorkRecord> records;
  final double dailyGoalHours;

  const WorkHeatmap({
    super.key,
    required this.records,
    this.dailyGoalHours = 8.0,
  });

  static const _weekdayLabels = ['一', '三', '五'];
  static const _weekdayLabelRows = {0, 2, 4};

  Color _cellColor(double hours, bool isDark) {
    if (hours == 0) {
      return isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEBEDF0);
    }
    if (hours < 4) return const Color(0xFF9C8FFF).withOpacity(0.4);
    if (hours < dailyGoalHours) return const Color(0xFF6C63FF).withOpacity(0.7);
    return const Color(0xFF6C63FF);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final firstDay = thisMonday.subtract(const Duration(days: 14 * 7));

    final Map<String, double> dailyTotals = {};
    for (final r in records) {
      final key = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
      dailyTotals[key] = (dailyTotals[key] ?? 0) + r.hoursWorked;
    }

    const cellSize = 16.0;
    const gap = 4.0;
    const colW = cellSize + gap;
    const rowH = cellSize + gap;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 22),
              for (int d = 0; d < 7; d++) ...[
                if (_weekdayLabelRows.contains(d))
                  SizedBox(
                    height: rowH,
                    child: Center(
                      child: Text(
                        _weekdayLabels[d == 0 ? 0 : d == 2 ? 1 : 2],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                else
                  SizedBox(height: rowH),
              ],
            ],
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 22,
                child: Row(
                  children: [
                    for (int w = 0; w < 15; w++) ...[
                      _MonthLabel(
                        date: firstDay.add(Duration(days: w * 7)),
                        width: colW,
                      ),
                    ],
                  ],
                ),
              ),
              for (int d = 0; d < 7; d++)
                Row(
                  children: [
                    for (int w = 0; w < 15; w++) ...[
                      _HeatmapCell(
                        date: firstDay.add(Duration(days: w * 7 + d)),
                        today: today,
                        hours: dailyTotals[
                            '${(firstDay.add(Duration(days: w * 7 + d))).year}-'
                            '${(firstDay.add(Duration(days: w * 7 + d))).month.toString().padLeft(2, '0')}-'
                            '${(firstDay.add(Duration(days: w * 7 + d))).day.toString().padLeft(2, '0')}'] ??
                            0,
                        color: _cellColor(
                          dailyTotals[
                              '${(firstDay.add(Duration(days: w * 7 + d))).year}-'
                              '${(firstDay.add(Duration(days: w * 7 + d))).month.toString().padLeft(2, '0')}-'
                              '${(firstDay.add(Duration(days: w * 7 + d))).day.toString().padLeft(2, '0')}'] ??
                              0,
                          isDark,
                        ),
                        size: cellSize,
                        gap: gap,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthLabel extends StatelessWidget {
  final DateTime date;
  final double width;

  const _MonthLabel({required this.date, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        '${date.month}月',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final double hours;
  final Color color;
  final double size;
  final double gap;

  const _HeatmapCell({
    required this.date,
    required this.today,
    required this.hours,
    required this.color,
    required this.size,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: gap, bottom: gap),
      child: Tooltip(
        message: '${date.month}月${date.day}日 ${hours.toStringAsFixed(1)}h',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: date.isAfter(today) ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
