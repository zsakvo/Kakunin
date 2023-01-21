import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:totp/data/entity/config.dart';
import 'package:totp/utils/log.dart';
import 'package:window_manager/window_manager.dart';

final _box = Hive.box<Config>("config");

class ConfigNotifier extends StateNotifier<Config> {
  ConfigNotifier() : super(_box.get("global")!);

  toggleAutoStart() {
    state = state.copyWith(autoStart: !state.autoStart!);
    saveConfig();
  }

  toggleShowNotification() {
    state = state.copyWith(showNotification: !state.showNotification!);
    saveConfig();
  }

  toggleSkipDock() {
    bool val = !state.skipDock!;
    state = state.copyWith(skipDock: val);
    windowManager.setSkipTaskbar(val);
    saveConfig();
  }

  saveConfig() {
    _box.put("global", state);
  }
}

final configProvider = StateNotifierProvider<ConfigNotifier, Config>((ref) {
  return ConfigNotifier();
});
