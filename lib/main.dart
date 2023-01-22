import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:kakunin/data/entity/config.dart';
import 'package:kakunin/data/entity/token.dart';
import 'package:kakunin/main_provider.dart';
import 'package:kakunin/screens/auth/auth_screen.dart';
import 'package:kakunin/screens/code/code_screen.dart';
import 'package:kakunin/screens/config/config_screen.dart';
import 'package:kakunin/utils/log.dart';
import 'package:window_manager/window_manager.dart';

import 'package:timezone/data/latest.dart' as timezone;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timezone.initializeTimeZones();
  await Hive.initFlutter();
  Hive.registerAdapter(ConfigAdapter());
  Hive.registerAdapter(TokenAdapter());
  await Hive.openBox<Token>('2fa');
  final configBox = await Hive.openBox<Config>('config');
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: const Size(420, 840),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: configBox.get("global")!.skipDock!,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.setResizable(false);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  await localNotifier.setup(
    appName: '二步验证',
    // 参数 shortcutPolicy 仅适用于 Windows
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MacosApp(
        title: 'Kakunin',
        theme: MacosThemeData.light(),
        darkTheme: MacosThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const MainView(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}

class MainView extends StatefulHookConsumerWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with WindowListener {
  @override
  void onWindowFocus() {
    // Make sure to call once.
    Log.d("focus");
    // do something
  }

  @override
  void onWindowBlur() {
    Log.d("blur");
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      windowManager.addListener(this);
      return () => windowManager.removeListener(this);
    });
    final pageIndex = ref.watch(pageProvider);
    return PlatformMenuBar(
      menus: const [
        PlatformMenu(
          label: 'Kakunin',
          menus: [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.about,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      child: MacosWindow(
        child: IndexedStack(
          index: pageIndex,
          children: [
            const AuthScreen(),
            CodeScreen(
              key: UniqueKey(),
            ),
            const ConfigScreen()
          ],
        ),
      ),
    );
  }
}
