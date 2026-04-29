import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  double hourlyRate;

  AppSettings({this.hourlyRate = 30.0});

  factory AppSettings.defaults() => AppSettings(hourlyRate: 30.0);
}
