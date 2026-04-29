import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/app_settings.dart';
import 'models/work_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(WorkRecordAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  await Hive.openBox<WorkRecord>('records');
  await Hive.openBox<AppSettings>('settings');

  runApp(
    const ProviderScope(child: App()),
  );
}
