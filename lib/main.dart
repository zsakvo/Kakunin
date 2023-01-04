import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:totp/screens/auth/auth_screen.dart';
import 'package:totp/screens/code/code_screen.dart';

void main() {
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

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _pageIndex = 1;

  @override
  Widget build(BuildContext context) {
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
          index: _pageIndex,
          children: const [AuthScreen(), CodeScreen()],
        ),
      ),
    );
  }
}
