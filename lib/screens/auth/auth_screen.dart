import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp/data/entity/totp.dart';
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
    // TODO: implement initState
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
    final String value = ref.watch(helloWorldProvider);
    final List<TotpItem> totpItems = ref.watch(totpItemsProvider);
    return ContentArea(
      builder: (context, scrollController) {
        return MacosScaffold(
          toolBar: const ToolBar(
            title: Text("身份验证器"),
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
                return Column(
                  children: [
                    // Container(
                    //   height: 2,
                    //   child: LinearProgressIndicator(
                    //     minHeight: 2,
                    //     value: controller.value,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 8,
                    ),
                    ...totpItems.map((e) {
                      final Totp totp = e.totp;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                              color: MacosTheme.of(context).primaryColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              Text(
                                "${totp.issuer ?? ""}:${totp.label!}",
                                style: const TextStyle(fontSize: 16, fontFamily: "Monaco"),
                              ),
                              const Spacer(),
                              Text(
                                e.currentCode,
                                style: const TextStyle(fontSize: 20, fontFamily: "Monaco"),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
