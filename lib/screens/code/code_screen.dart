import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

class CodeScreen extends StatefulHookConsumerWidget {
  const CodeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text("新增凭证"),
        actions: const [
          ToolBarIconButton(label: "保存", icon: MacosIcon(CupertinoIcons.arrow_down_doc), showLabel: false)
        ],
        leading: MacosBackButton(
          fillColor: Colors.transparent,
          onPressed: () {
            // print("click");
          },
        ),
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 90),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: const [
                        Text("链接"),
                        SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          placeholder: '输入otpauth链接',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 16,
                    color: Colors.grey[100],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: const [
                        Text("服务商"),
                        SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          placeholder: '设置服务商',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: const [
                        Text("名称"),
                        SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          placeholder: '名称',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: const [
                        Text("密钥"),
                        SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          placeholder: '密钥',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 16,
                    color: Colors.grey[100],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(children: [
                      const Text("加密类型"),
                      const SizedBox(
                        width: 14,
                      ),
                      MacosPulldownButton(title: "TOTP", items: [
                        MacosPulldownMenuItem(
                          title: const Text('TOTP'),
                          onTap: () => debugPrint("Saving..."),
                        ),
                        MacosPulldownMenuItem(
                          title: const Text('HOTP'),
                          onTap: () => debugPrint("Opening Save As dialog..."),
                        ),
                      ]),
                      const Spacer(),
                      const Text("哈希函数"),
                      const SizedBox(
                        width: 14,
                      ),
                      MacosPulldownButton(title: "SHA1", items: [
                        MacosPulldownMenuItem(
                          title: const Text('SHA1'),
                          onTap: () => debugPrint("Saving..."),
                        ),
                        MacosPulldownMenuItem(
                          title: const Text('SHA256'),
                          onTap: () => debugPrint("Opening Save As dialog..."),
                        ),
                        MacosPulldownMenuItem(
                          title: const Text('SHA512'),
                          onTap: () => debugPrint("Opening Save As dialog..."),
                        ),
                      ]),
                      const Spacer(),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: const [
                        Text("时间"),
                        SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          placeholder: '时间间隔',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: const [
                        Text("位数"),
                        SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          placeholder: '位数',
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
