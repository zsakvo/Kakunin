import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:totp/data/entity/totp.dart';
import 'package:totp/main_provider.dart';
import 'package:totp/screens/auth/auth_screen.dart';
import 'package:totp/screens/code/code_screen.dart';
import 'package:totp/screens/config/config_screen.dart';
import 'package:totp/utils/log.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(420, 840),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  await localNotifier.setup(
    appName: '二步验证',
    // 参数 shortcutPolicy 仅适用于 Windows
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(TotpAdapter());
  await Hive.openBox<Totp>('2fa');

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MacosApp(
        title: 'totp',
        theme: MacosThemeData.light(),
        darkTheme: MacosThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const MainView(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(pageProvider);
    return PlatformMenuBar(
      menus: const [
        PlatformMenu(
          label: 'Totp',
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


// class MainView extends StatefulWidget {
//   const MainView({super.key});

//   @override
//   State<MainView> createState() => _MainViewState();
// }

// class _MainViewState extends State<MainView> {
//   // int _pageIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return PlatformMenuBar(
//       menus: const [
//         PlatformMenu(
//           label: 'Totp',
//           menus: [
//             PlatformProvidedMenuItem(
//               type: PlatformProvidedMenuItemType.about,
//             ),
//             PlatformProvidedMenuItem(
//               type: PlatformProvidedMenuItemType.quit,
//             ),
//           ],
//         ),
//       ],
//       child: MacosWindow(
//         child: IndexedStack(
//           index: _pageIndex,
//           children: const [AuthScreen(), CodeScreen()],
//         ),
//       ),
//     );
//   }
// }
