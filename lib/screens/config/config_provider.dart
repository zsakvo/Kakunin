import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:totp/data/entity/config.dart';

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
    state = state.copyWith(skipDock: !state.skipDock!);
    saveConfig();
  }

  saveConfig() {
    _box.put("global", state);
  }
}

final configProvider = StateNotifierProvider<ConfigNotifier, Config>((ref) {
  return ConfigNotifier();
});
