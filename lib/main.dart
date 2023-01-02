import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:totp/screens/auth/auth_screen.dart';

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
  int _pageIndex = 0;

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
        // sidebar: Sidebar(
        //   minWidth: 200,
        //   builder: (context, scrollController) => SidebarItems(
        //     currentIndex: _pageIndex,
        //     onChanged: (index) {
        //       setState(() => _pageIndex = index);
        //     },
        //     items: const [
        //       SidebarItem(
        //         leading: MacosIcon(CupertinoIcons.arrow_down_right_arrow_up_left),
        //         label: Text('密钥'),
        //       ),
        //       SidebarItem(
        //         leading: MacosIcon(CupertinoIcons.settings),
        //         label: Text('设置'),
        //       ),
        //       SidebarItem(
        //         leading: MacosIcon(CupertinoIcons.compass),
        //         label: Text('关于'),
        //       ),
        //     ],
        //   ),
        // ),
        child: IndexedStack(
          index: _pageIndex,
          children: const [
            AuthScreen(),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MacosScaffold(
          toolBar: const ToolBar(
            title: Text('身份验证器'),
            padding: EdgeInsets.only(top: 4, bottom: 4, left: 90),
            actions: [
              ToolBarIconButton(
                  label: "手动导入", icon: MacosIcon(CupertinoIcons.chevron_left_slash_chevron_right), showLabel: false),
              ToolBarIconButton(label: "文件导入", icon: MacosIcon(CupertinoIcons.doc_text_viewfinder), showLabel: false),
              ToolBarIconButton(label: "设置", icon: MacosIcon(CupertinoIcons.settings), showLabel: false)
            ],
          ),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return const Center(
                  child: Text('身份验证器'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
