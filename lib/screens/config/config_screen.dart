// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:kakunin/data/entity/token.dart';
import 'package:kakunin/screens/config/config_provider.dart';
import 'package:kakunin/utils/flash.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/entity/config.dart';
import '../../main_provider.dart';
import '../auth/auth_provider.dart';

class ConfigScreen extends StatefulHookConsumerWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
    Config config = ref.watch(configProvider);
    ConfigNotifier configNotifier = ref.read(configProvider.notifier);
    return ContentArea(
      builder: (context, scrollController) {
        return MacosScaffold(
          toolBar: ToolBar(
            title: const Text("程序偏好设置"),
            leading: MacosBackButton(
              fillColor: Colors.transparent,
              onPressed: () {
                ref.read(pageProvider.notifier).update((state) => 0);
              },
            ),
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 90),
          ),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("开机自启动"),
                            Transform.translate(
                              offset: const Offset(12, 0),
                              child: Transform.scale(
                                scaleX: 0.6,
                                scaleY: 0.6,
                                child: MacosSwitch(
                                  value: config.autoStart!,
                                  onChanged: (value) {
                                    configNotifier.toggleAutoStart();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("复制成功弹出通知"),
                            Transform.translate(
                              offset: const Offset(12, 0),
                              child: Transform.scale(
                                scaleX: 0.6,
                                scaleY: 0.6,
                                child: MacosSwitch(
                                  value: config.showNotification!,
                                  onChanged: (value) {
                                    configNotifier.toggleShowNotification();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("隐藏Dock图标"),
                            Transform.translate(
                              offset: const Offset(12, 0),
                              child: Transform.scale(
                                scaleX: 0.6,
                                scaleY: 0.6,
                                child: MacosSwitch(
                                  value: config.skipDock!,
                                  onChanged: (value) {
                                    configNotifier.toggleSkipDock();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "清空记录",
                                style: TextStyle(color: Color(0xffef5350), fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "这会清空你的全部记录，不会二次确认，请谨慎操作",
                                style: TextStyle(fontSize: 13, height: 1.8, color: Colors.grey[500]),
                              )
                            ],
                          ),
                        ),
                        onTap: () async {
                          var box = Hive.box<Token>("2fa");
                          await box.clear();
                          showSuccessToast(context, "数据清除完毕");
                          ref.read(tokenItemsProvider.notifier).update();
                        },
                      ),
                      const Divider(),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("关于应用"),
                              Text(
                                "基于 Flutter 构建， MacOS 样式的二步验证工具",
                                style: TextStyle(fontSize: 13, height: 1.8, color: Colors.grey[500]),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          launchUrl(Uri.parse("https://github.com/zsakvo/Kakunin"));
                        },
                      )
                    ],
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
