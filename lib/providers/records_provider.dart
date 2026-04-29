import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/work_record.dart';

class RecordsNotifier extends AsyncNotifier<List<WorkRecord>> {
  @override
  Future<List<WorkRecord>> build() async {
    final box = Hive.box<WorkRecord>('records');
    final records = box.values.toList();
    records.sort((a, b) {
      final dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;
      return b.startMinutes.compareTo(a.startMinutes);
    });
    return records;
  }

  Future<void> addRecord(WorkRecord r) async {
    final box = Hive.box<WorkRecord>('records');
    await box.put(r.id, r);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteRecord(String id) async {
    final box = Hive.box<WorkRecord>('records');
    await box.delete(id);
    ref.invalidateSelf();
    await future;
  }

  List<WorkRecord> recordsForMonth(int year, int month) {
    final records = state.valueOrNull ?? [];
    return records
        .where((r) => r.date.year == year && r.date.month == month)
        .toList();
  }

  double totalHoursThisWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart = DateTime(monday.year, monday.month, monday.day);
    final records = state.valueOrNull ?? [];
    return records
        .where((r) => !r.date.isBefore(mondayStart))
        .fold<double>(0, (sum, r) => sum + r.hoursWorked);
  }

  double totalHoursThisMonth() {
    final now = DateTime.now();
    final records = state.valueOrNull ?? [];
    return records
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold<double>(0, (sum, r) => sum + r.hoursWorked);
  }

  double totalEarningsThisWeek(double rate) =>
      totalHoursThisWeek() * rate;

  double totalEarningsThisMonth(double rate) =>
      totalHoursThisMonth() * rate;
}

final recordsProvider =
    AsyncNotifierProvider<RecordsNotifier, List<WorkRecord>>(
  RecordsNotifier.new,
);
