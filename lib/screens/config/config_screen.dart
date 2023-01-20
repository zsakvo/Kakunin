import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../main_provider.dart';

class ConfigScreen extends StatefulHookConsumerWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
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
                return ListView(
                  children: [
                    Row(
                      children: [Text("开机自启动")],
                    )
                  ],
                );
              },
            )
          ],
        );
      },
    );
  }
}
