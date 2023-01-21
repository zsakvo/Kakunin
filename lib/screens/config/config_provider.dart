import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:totp/data/entity/config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

final _box = Hive.box<Config>("config");

class ConfigNotifier extends StateNotifier<Config> {
  ConfigNotifier() : super(_box.get("global")!);

  toggleAutoStart() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
    );
    bool isEnabled = await launchAtStartup.isEnabled();
    if (isEnabled) {
      launchAtStartup.disable();
    } else {
      launchAtStartup.enable();
    }
    isEnabled = await launchAtStartup.isEnabled();
    state = state.copyWith(autoStart: isEnabled);
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
