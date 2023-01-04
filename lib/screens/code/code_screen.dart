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
        title: Text("新增凭证"),
        leading: MacosBackButton(
          fillColor: Colors.transparent,
          onPressed: () {
            print("click");
          },
        ),
        padding: EdgeInsets.only(top: 4, bottom: 4, left: 90),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
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
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
