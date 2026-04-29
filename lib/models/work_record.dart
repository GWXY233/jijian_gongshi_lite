import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'work_record.g.dart';

@HiveType(typeId: 0)
class WorkRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int startMinutes;

  @HiveField(3)
  final int endMinutes;

  double get hoursWorked => (endMinutes - startMinutes) / 60.0;

  String get startTimeStr {
    final h = startMinutes ~/ 60;
    final m = startMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String get endTimeStr {
    final h = endMinutes ~/ 60;
    final m = endMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String get durationStr {
    final totalMinutes = endMinutes - startMinutes;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '${mins}分';
    return '${hours}小时${mins}分';
  }

  WorkRecord({
    required this.id,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
  });

  factory WorkRecord.create({
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
  }) {
    return WorkRecord(
      id: const Uuid().v4(),
      date: DateTime(date.year, date.month, date.day),
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
  }
}
