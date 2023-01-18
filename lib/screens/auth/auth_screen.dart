import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp/data/entity/totp.dart';
import 'package:totp/main_provider.dart';
import 'package:totp/screens/auth/auth_provider.dart';
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

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      value: 1.0,

      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 30),
      reverseDuration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {
          if (controller.value == 0) {
            controller.value = 1.0;
            controller.reverse();
          }
        });
      });
    // controller.reverse(from: controller.upperBound);
    // controller.repeat(reverse: false);
    controller.reverse();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<TotpItem> totpItems = ref.watch(totpItemsProvider);
    return ContentArea(
      builder: (context, scrollController) {
        return MacosScaffold(
          toolBar: ToolBar(
            title: const Text("身份验证器"),
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 90),
            actions: [
              ToolBarIconButton(
                  label: "手动导入",
                  icon: const MacosIcon(CupertinoIcons.chevron_left_slash_chevron_right),
                  showLabel: false,
                  onPressed: () {
                    ref.read(pageProvider.notifier).update((state) => 1);
                  }),
              const ToolBarIconButton(label: "编辑模式", icon: MacosIcon(CupertinoIcons.bandage), showLabel: false),
              const ToolBarIconButton(label: "设置", icon: MacosIcon(CupertinoIcons.settings), showLabel: false)
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
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          totp.issuer ?? "",
                                          style: const TextStyle(fontSize: 16, fontFamily: "Monaco"),
                                        ),
                                        Text(
                                          " (${totp.label!})",
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
                                ProgressCircle(
                                  value: item.timeValue,
                                  innerColor: Colors.blue,
                                  radius: 11,
                                ),
                              ],
                            ),
                          ),
                        );
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
}
