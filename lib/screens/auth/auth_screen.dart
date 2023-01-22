import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:contextual_menu/contextual_menu.dart';
import 'package:flutter/cupertino.dart' hide MenuItem;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp/data/entity/totp.dart';
import 'package:totp/main_provider.dart';
import 'package:totp/screens/auth/auth_provider.dart';
import 'package:totp/screens/config/config_provider.dart';
import 'package:totp/utils/flash.dart';
import 'package:totp/utils/log.dart';
import 'package:tray_manager/tray_manager.dart';

part 'auth_screen.g.dart';

@riverpod
String helloWorld(HelloWorldRef ref) {
  return '身份验证器';
}

@riverpod
double progressValue(ProgressValueRef ref) {
  return 1.0;
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin, TrayListener {
  late AnimationController controller;

  bool _shouldReact = false;
  Offset? _position;
  final Placement _placement = Placement.bottomLeft;

  Menu? _menu;

  @override
  void onTrayIconMouseDown() {
    Log.d('onTrayIconMouseDown');
    var totpItems = ref.read(totpItemsProvider);
    final menuItems = totpItems
        .map((e) => e.totp.scheme == "TOTP"
            ? MenuItem(label: "${e.totp.label}\t\t${e.currentCode}\t\t${e.leftTime.toInt().toString()}秒")
            : MenuItem(label: "${e.totp.label}\t\t${e.currentCode}\t\t${e.totp.count.toString()}次"))
        .toList();
    menuItems.addAll([MenuItem.separator(), MenuItem(label: "退出")]);
    menuItems.insert(0, MenuItem(label: "当前验证码", disabled: true));
    trayManager.setContextMenu(Menu(items: menuItems));
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconMouseUp() {
    Log.d('onTrayIconMouseUp');
  }

  @override
  void onTrayIconRightMouseDown() {
    Log.d('onTrayIconRightMouseDown');
    // trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    Log.d('onTrayIconRightMouseUp');
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.label!.contains("\t")) {
      final arr = menuItem.label!.split("\t\t");
      final code = arr[1];
      final label = arr[0];
      FlutterClipboard.copy(code).then((value) {
        if (ref.read(configProvider).showNotification!) {
          LocalNotification(
            title: label,
            body: "验证码复制成功",
          ).show();
        }
      });
    } else {
      exit(0);
    }
  }

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    trayManager.setIcon("assets/img/tray_icon.png");
    super.initState();
    ref.read(totpItemsProvider.notifier).chronometer();
    // final menuItems = <MenuItem>[];
    // menuItems.insert(0, MenuItem(label: "当前验证码", disabled: false));
    // trayManager.setContextMenu(Menu(items: menuItems));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Totp>("2fa");
    final bool isEditing = ref.watch(editorProvider);
    final Totp? editItem = ref.watch(editItemProvider);
    final List<TotpItem> totpItems = ref.watch(totpItemsProvider);
    // final menuItems = totpItems.map((e) => MenuItem(label: "${e.totp.label}\t\t\t\t${e.currentCode}")).toList();
    // menuItems.addAll([MenuItem.separator(), MenuItem(label: "退出")]);
    // menuItems.insert(0, MenuItem(label: "当前验证码", disabled: true));
    // trayManager.setContextMenu(Menu(items: menuItems));
    return ContentArea(
      builder: (context, scrollController) {
        return MacosScaffold(
          toolBar: ToolBar(
            title: const Text("身份验证器"),
            leading: isEditing
                ? MacosBackButton(
                    fillColor: Colors.transparent,
                    onPressed: () {
                      ref.read(editorProvider.notifier).update((state) => false);
                    },
                  )
                : null,
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 90),
            actions: !isEditing
                ? [
                    ToolBarIconButton(
                        label: "手动导入",
                        icon: const MacosIcon(CupertinoIcons.bandage),
                        showLabel: false,
                        onPressed: () {
                          ref.read(editItemProvider.notifier).update((state) => null);
                          ref.read(pageProvider.notifier).update((state) => 1);
                        }),
                    // const ToolBarIconButton(label: "编辑模式", icon: MacosIcon(CupertinoIcons.chevron_left_slash_chevron_right), showLabel: false),
                    ToolBarIconButton(
                        label: "设置",
                        icon: const MacosIcon(CupertinoIcons.settings),
                        showLabel: false,
                        onPressed: () {
                          ref.read(pageProvider.notifier).update((state) => 2);
                        })
                  ]
                : [
                    ToolBarIconButton(
                        label: "编辑",
                        icon: const MacosIcon(CupertinoIcons.ellipsis),
                        showLabel: false,
                        onPressed: () {
                          ref.read(editorProvider.notifier).update((state) => false);
                          ref.read(pageProvider.notifier).update((state) => 1);
                        }),
                    ToolBarIconButton(
                        label: "删除",
                        icon: const MacosIcon(
                          CupertinoIcons.trash,
                          color: Color(0xffef5350),
                        ),
                        showLabel: false,
                        onPressed: () async {
                          ref.read(editorProvider.notifier).update((state) => false);
                          await box.delete(editItem!.uuid);
                          ref.read(totpItemsProvider.notifier).update();
                        })
                  ],
          ),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        final item = totpItems[index];
                        final Totp totp = item.totp;
                        return Listener(
                            onPointerDown: (event) {
                              _shouldReact =
                                  event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton;
                            },
                            onPointerUp: (event) {
                              if (!_shouldReact) return;

                              ref.read(editItemProvider.notifier).update((state) => totp);

                              _position = Offset(
                                event.position.dx,
                                event.position.dy,
                              );

                              _handleClickPopUp(totp);
                            },
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Container(
                                color: isEditing && editItem == totp ? Colors.blue[50] : Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: totp.issuer!.isNotEmpty
                                                ? [
                                                    Text(
                                                      totp.issuer!,
                                                      style: const TextStyle(fontSize: 16, fontFamily: "Monaco"),
                                                    ),
                                                    Text(
                                                      " (${totp.label!})",
                                                      style: const TextStyle(
                                                          fontSize: 15, fontFamily: "Monaco", color: Color(0xFF919191)),
                                                    )
                                                  ]
                                                : [
                                                    Text(
                                                      totp.label!,
                                                      style: const TextStyle(
                                                          fontSize: 15, fontFamily: "Monaco", color: Color(0xFF919191)),
                                                    )
                                                  ],
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            item.currentCode,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: "Monaco",
                                                color: Theme.of(context).colorScheme.primary),
                                          )
                                        ],
                                      ),
                                      const Spacer(),
                                      // AnimatedLiquidCircularProgressIndicator(),
                                      totp.scheme == "TOTP"
                                          ? ProgressCircle(
                                              value: item.timeValue,
                                              innerColor: Colors.blue,
                                              radius: 11,
                                            )
                                          : GestureDetector(
                                              child: Transform.translate(
                                                offset: const Offset(14.0, 0),
                                                child: Container(
                                                    color: Colors.transparent,
                                                    padding: const EdgeInsets.all(14),
                                                    child: const MacosIcon(CupertinoIcons.arrow_clockwise)),
                                              ),
                                              onTap: () {
                                                ref.read(totpItemsProvider.notifier).updateHotp(item);
                                              },
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (isEditing) {
                                  ref.read(editItemProvider.notifier).update((state) => totp);
                                } else {
                                  FlutterClipboard.copy(item.currentCode)
                                      .then((value) => showSuccessToast(context, "验证码拷贝成功"));
                                }
                              },
                              onLongPress: () {
                                ref.read(editItemProvider.notifier).update((state) => totp);
                                ref.read(editorProvider.notifier).update((state) => true);
                              },
                            ));
                      },
                      separatorBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Divider(
                            indent: 16,
                            endIndent: 16,
                            color: Colors.black,
                            thickness: 0.1,
                          ),
                        );
                      },
                      itemCount: totpItems.length),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _onClick(MenuItem item, Totp totp) async {
    final box = Hive.box<Totp>("2fa");
    switch (item.label) {
      case "编辑":
        ref.read(pageProvider.notifier).update((state) => 1);
        break;
      case "删除":
        await box.delete(totp.uuid);
        ref.read(totpItemsProvider.notifier).remove(totp);
        break;
    }
  }

  void _handleClickPopUp(Totp totp) {
    _menu ??= Menu(
      items: [
        MenuItem(
          label: '编辑',
          onClick: (MenuItem menuItem) => _onClick(menuItem, totp),
        ),
        MenuItem(
          label: '删除',
          onClick: (MenuItem menuItem) => _onClick(menuItem, totp),
        ),
      ],
    );
    popUpContextualMenu(
      _menu!,
      position: _position,
      placement: _placement,
    );
  }
}
