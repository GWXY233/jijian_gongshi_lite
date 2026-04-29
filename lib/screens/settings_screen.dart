import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../models/work_record.dart';
import '../providers/records_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    final rate = ref.read(settingsProvider).valueOrNull?.hourlyRate ?? 30;
    final text = rate == rate.roundToDouble()
        ? rate.toInt().toString()
        : rate.toStringAsFixed(2);
    _rateController = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _saveRate() {
    final v = double.tryParse(_rateController.text);
    if (v != null && v > 0) {
      ref.read(settingsProvider.notifier).updateHourlyRate(v);
    }
  }

  Future<void> _exportCsv() async {
    final records = ref.read(recordsProvider).valueOrNull ?? [];
    if (records.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('暂无记录')));
      }
      return;
    }
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final lines = ['日期,星期,上班,下班,工时(小时),收入(元)'];
    final rate = ref.read(settingsProvider).valueOrNull?.hourlyRate ?? 0;
    for (final r in records) {
      final earnings = (r.hoursWorked * rate).toStringAsFixed(2);
      lines.add(
          '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')},'
          '周${weekdays[r.date.weekday - 1]},'
          '${r.startTimeStr},${r.endTimeStr},'
          '${r.hoursWorked.toStringAsFixed(2)},$earnings');
    }
    final csv = lines.join('\n');
    await Share.share(csv, subject: '工时记录.csv');
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空数据'),
        content: const Text('确认清空所有工时记录？此操作不可恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消')),
          TextButton(
            onPressed: () {
              Hive.box<WorkRecord>('records').clear();
              ref.invalidate(recordsProvider);
              Navigator.pop(ctx);
            },
            child: const Text('确认',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = const Color(0xFF6C63FF);
    final sec = theme.colorScheme.onSurface.withOpacity(0.6);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('工作设置'),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('时薪',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('设置后将自动计算每日收入',
                      style: TextStyle(color: sec, fontSize: 13)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      suffixText: '元 / 小时',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onEditingComplete: _saveRate,
                    onTapOutside: (_) {
                      FocusScope.of(context).unfocus();
                      _saveRate();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('数据管理'),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.download_outlined, color: primary),
                  title: const Text('导出 CSV'),
                  subtitle: Text('通过系统分享导出所有记录', style: TextStyle(color: sec)),
                  onTap: _exportCsv,
                ),
                const Divider(height: 1, indent: 16),
                ListTile(
                  leading:
                      const Icon(Icons.delete_outlined, color: Colors.red),
                  title: const Text('清空所有数据',
                      style: TextStyle(color: Colors.red)),
                  onTap: _confirmClear,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('关于'),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: const Text('版本'),
              trailing: Text('v1.0.0',
                  style: TextStyle(color: sec)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
    );
  }
}
