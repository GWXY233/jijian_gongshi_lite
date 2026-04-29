import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/records_provider.dart';
import '../providers/settings_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  bool _isWeekView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sec = theme.colorScheme.onSurface.withOpacity(0.6);
    final recordsAsync = ref.watch(recordsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final rate = settingsAsync.valueOrNull?.hourlyRate ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        centerTitle: false,
        elevation: 0,
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('加载失败')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_outlined, size: 72, color: sec),
                  const SizedBox(height: 16),
                  const Text('暂无数据',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            );
          }
          return _buildContent(records, rate, theme, sec);
        },
      ),
    );
  }

  Widget _buildContent(
      List records, double rate, ThemeData theme, Color sec) {
    final now = DateTime.now();

    List<double> dailyHours;
    List<String> xLabels;
    double barWidth;
    String title1, value1, title2, value2, title3, value3;

    if (_isWeekView) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      dailyHours = List.generate(7, (i) {
        final d = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
        return records
            .where((r) =>
                r.date.year == d.year &&
                r.date.month == d.month &&
                r.date.day == d.day)
            .fold<double>(0, (s, r) => s + r.hoursWorked);
      });
      xLabels = ['一', '二', '三', '四', '五', '六', '日'];
      barWidth = 20;

      final total = dailyHours.fold<double>(0, (s, v) => s + v);
      final daysWithRecords = dailyHours.where((h) => h > 0).length;
      final goalDays = dailyHours.where((h) => h >= 8).length;
      title1 = '本周总计';
      value1 = '${total.toStringAsFixed(1)}h';
      title2 = '日均';
      value2 = daysWithRecords > 0
          ? '${(total / daysWithRecords).toStringAsFixed(1)}h'
          : '0h';
      title3 = '达标天数';
      value3 = '${goalDays}天';
    } else {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      dailyHours = List.generate(daysInMonth, (i) {
        final d = DateTime(now.year, now.month, i + 1);
        return records
            .where((r) =>
                r.date.year == d.year &&
                r.date.month == d.month &&
                r.date.day == d.day)
            .fold<double>(0, (s, r) => s + r.hoursWorked);
      });
      xLabels = List.generate(daysInMonth, (i) {
        final day = i + 1;
        if (day == 1 ||
            day == 5 ||
            day == 10 ||
            day == 15 ||
            day == 20 ||
            day == 25 ||
            day == 31) return day.toString();
        return '';
      });
      barWidth = 8;

      final total = dailyHours.fold<double>(0, (s, v) => s + v);
      final workDays = dailyHours.where((h) => h > 0).length;
      final goalDays = dailyHours.where((h) => h >= 8).length;
      title1 = '本月总计';
      value1 = '${total.toStringAsFixed(1)}h';
      title2 = '工作天数';
      value2 = '${workDays}天';
      title3 = '达标天数';
      value3 = '${goalDays}天';
    }

    final maxY = (dailyHours.reduce((a, b) => a > b ? a : b).ceilToDouble()
            .clamp(8.0, double.infinity) + 1.0)
        .toDouble();

    final bars = dailyHours.asMap().entries.map((e) {
      final val = e.value;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: val,
            color: val >= 8
                ? const Color(0xFF4834D4)
                : const Color(0xFF6C63FF),
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('本周')),
              ButtonSegment(value: false, label: Text('本月')),
            ],
            selected: {_isWeekView},
            onSelectionChanged: (v) => setState(() => _isWeekView = v.first),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  barGroups: bars,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= xLabels.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              xLabels[idx],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 8,
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ],
                  ),
                  barTouchData: BarTouchData(enabled: false),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatCard(value: value1, label: title1),
            _StatCard(value: value2, label: title2),
            _StatCard(value: value3, label: title3),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final sec = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF6C63FF)),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: sec),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
