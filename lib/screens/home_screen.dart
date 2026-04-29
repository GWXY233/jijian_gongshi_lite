import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../models/work_record.dart';
import '../providers/records_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/add_record_sheet.dart';
import '../widgets/record_card.dart';
import '../widgets/work_heatmap.dart';

Color _secondary(ThemeData t) => t.colorScheme.onSurface.withOpacity(0.6);

class _SummaryCard extends StatelessWidget {
  final String label;
  final double hours;
  final double earnings;

  const _SummaryCard(this.label, this.hours, this.earnings);

  @override
  Widget build(BuildContext context) {
    final sec = _secondary(Theme.of(context));
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0x1F6C63FF),
              Color(0x149C8FFF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: sec, fontSize: 13)),
            const SizedBox(height: 4),
            Text('${hours.toStringAsFixed(1)}h',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF6C63FF))),
            if (earnings > 0) ...[
              const SizedBox(height: 2),
              Text('¥${earnings.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF4CAF50))),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showRecordActions(BuildContext context, WidgetRef ref, WorkRecord record) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
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
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFF6C63FF)),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => ProviderScope(
                    parent: ProviderScope.containerOf(context),
                    child: AddRecordSheet(record: record),
                  ),
                );
              },
            ),
            const Divider(height: 1, indent: 16),
            ListTile(
              leading: const Icon(Icons.delete_outlined, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('删除记录'),
                    content: const Text('确认删除这条记录？'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(d),
                          child: const Text('取消')),
                      TextButton(
                        onPressed: () {
                          ref.read(recordsProvider.notifier).deleteRecord(record.id);
                          Navigator.pop(d);
                        },
                        child: const Text('确认', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('工时记录',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _buildBody(context, ref, theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => ProviderScope(
              parent: ProviderScope.containerOf(context),
              child: const AddRecordSheet()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('记录今天'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ThemeData theme) {
    final recordsAsync = ref.watch(recordsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final sec = _secondary(theme);

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('加载失败')),
      data: (records) {
        final empty = records.isEmpty;
        final rate = settingsAsync.valueOrNull?.hourlyRate ?? 0.0;

        if (empty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 72, color: sec),
                const SizedBox(height: 16),
                Text('暂无记录',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('点击右下角「记录今天」开始',
                    style: TextStyle(fontSize: 14, color: sec)),
              ],
            ),
          );
        }

        final notifier = ref.read(recordsProvider.notifier);
        final weekHours = notifier.totalHoursThisWeek();
        final weekEarnings = notifier.totalEarningsThisWeek(rate);
        final monthHours = notifier.totalHoursThisMonth();
        final monthEarnings = notifier.totalEarningsThisMonth(rate);

        final Map<String, List<WorkRecord>> grouped = {};
        for (final r in records) {
          final key = '${r.date.year}-${r.date.month}';
          grouped.putIfAbsent(key, () => []).add(r);
        }
        final sortedKeys =
            grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _SummaryCard('本周', weekHours, weekEarnings),
                    const SizedBox(width: 12),
                    _SummaryCard('本月', monthHours, monthEarnings),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('工作热力图',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: sec)),
                    const SizedBox(height: 8),
                    WorkHeatmap(
                      records: records,
                      dailyGoalHours: 8.0,
                    ),
                  ],
                ),
              ),
            ),
            for (final key in sortedKeys) ...[
              SliverToBoxAdapter(
                child: _buildMonthHeader(
                    context, key, grouped[key]!, rate, sec),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  grouped[key]!
                      .map((r) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: RecordCard(
                              record: r,
                              hourlyRate: rate,
                              onLongPress: () =>
                                  _showRecordActions(context, ref, r),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMonthHeader(BuildContext context, String key,
      List<WorkRecord> records, double rate, Color sec) {
    final parts = key.split('-');
    final year = parts[0];
    final month = parts[1];
    final totalHours =
        records.fold<double>(0, (s, r) => s + r.hoursWorked);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('${year}年${month}月',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: sec)),
          const Spacer(),
          Text(
            '共${totalHours.toStringAsFixed(1)}h${rate > 0 ? ' · ¥${(totalHours * rate).toStringAsFixed(0)}' : ''}',
            style: TextStyle(color: sec, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
