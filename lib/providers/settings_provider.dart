import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/app_settings.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    try {
      final box = Hive.box<AppSettings>('settings');
      return box.get('cfg') ?? AppSettings.defaults();
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  Future<void> updateHourlyRate(double rate) async {
    state = AsyncValue.data(state.requireValue..hourlyRate = rate);
    await Hive.box<AppSettings>('settings').put('cfg', state.requireValue);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
