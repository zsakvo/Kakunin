// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/utils/flash.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mime/mime.dart';
import 'package:kakunin/data/entity/token.dart';
import 'package:kakunin/main_provider.dart';
import 'package:kakunin/screens/auth/auth_provider.dart';
import 'package:kakunin/screens/code/code_provider.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/qr.dart';
import 'package:uuid/uuid.dart';

class CodeScreen extends StatefulHookConsumerWidget {
  const CodeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var uuid = const Uuid();
    var uuidVal = useState<String?>(null);
    // final Token token = ref.watch(codeEditorProvider);
    final Token editItem = ref.watch(editItemProvider);
    final isDragging = ref.watch(dragProvider);
    final uriTextController = useTextEditingController();
    final issuerTextController = useTextEditingController();
    final labelTextController = useTextEditingController();
    final secrectTextController = useTextEditingController();
    final periodTextController = useTextEditingController(text: "30");
    final digitsTextController = useTextEditingController(text: "6");
    final countTextController = useTextEditingController(text: "0");

    uriValueListener() {
      final uriText = uriTextController.text;
      final uri = Uri.parse(uriText);
      if (uri.scheme != "otpauth") return;
      final scheme = uri.host.toUpperCase();
      final path = uri.path.replaceAll("/", "");
      final querMaps = uri.queryParameters;
      final secret = querMaps["secret"] ?? "";
      final issuer = querMaps["issuer"] ?? "";
      final algorithm = (querMaps["algorithm"] ?? "SHA1").toUpperCase();
      final digits = querMaps["digits"] ?? "";
      final period = querMaps["period"] ?? "";
      issuerTextController.text = issuer;
      labelTextController.text = path;
      secrectTextController.text = secret;
      periodTextController.text = period.isNotEmpty ? period : "30";
      // ref.read(codeEditorProvider.notifier).setPeriod(int.tryParse(period) ?? 30);
      // ref.read(codeEditorProvider.notifier).setDigits(int.tryParse(digits) ?? 6);
      digitsTextController.text = digits.isNotEmpty ? digits : "6";

      if (scheme.isNotEmpty) {
        if (!["TOTP", "HOTP"].contains(scheme)) {
          Log.d("当前类型不被支持");
        } else {
          ref.read(editItemProvider.notifier).setScheme(scheme);
        }
      }
      if (!["SHA1", "SHA256", "SHA512"].contains(algorithm)) {
        Log.d("当前算法不被支持");
      } else {
        ref.read(editItemProvider.notifier).setAlgorithm(algorithm);
      }
    }

    tokenItemTextValueListener(String key, String value) {}

    issuerListener() => tokenItemTextValueListener("issuer", issuerTextController.text);
    labelListener() => tokenItemTextValueListener("label", labelTextController.text);
    secrectListener() => tokenItemTextValueListener("secrect", secrectTextController.text);
    periodListener() => tokenItemTextValueListener("period", periodTextController.text);
    digitsListenr() => tokenItemTextValueListener("digits", digitsTextController.text);

    useEffect(() {
      if (editItem.uuid != null) {
        uriTextController.text = editItem.otpauth ?? "";
        issuerTextController.text = editItem.issuer ?? "";
        labelTextController.text = editItem.label ?? "";
        secrectTextController.text = editItem.secret ?? "";
        periodTextController.text = editItem.period.toString();
        digitsTextController.text = editItem.digits.toString();
        countTextController.text = editItem.count.toString();
        uuidVal.value = editItem.uuid!;
      } else {
        uuidVal.value = uuid.v4();
        uriTextController.text = "";
        issuerTextController.text = "";
        labelTextController.text = "";
        secrectTextController.text = "";
      }

      uriTextController.addListener(uriValueListener);
      issuerTextController.addListener(issuerListener);
      labelTextController.addListener(labelListener);
      secrectTextController.addListener(secrectListener);
      periodTextController.addListener(periodListener);
      digitsTextController.addListener(digitsListenr);
      return () {
        uriTextController.removeListener(uriValueListener);
        issuerTextController.removeListener(issuerListener);
        labelTextController.removeListener(issuerListener);
        secrectTextController.removeListener(secrectListener);
        periodTextController.removeListener(periodListener);
        digitsTextController.removeListener(digitsListenr);
      };
    }, []);

    return MacosScaffold(
      toolBar: ToolBar(
        title: Text(editItem.uuid == null ? "新增凭证" : "编辑凭证"),
        actions: [
          ToolBarIconButton(
            label: "保存",
            icon: const MacosIcon(CupertinoIcons.arrow_down_doc),
            showLabel: false,
            onPressed: () {
              // print("click");
              var uri = Uri(
                  scheme: "otpauth",
                  host: ref.read(editItemProvider).scheme,
                  path: labelTextController.text,
                  queryParameters: {
                    "secrect": secrectTextController.text,
                    "issuer": issuerTextController.text,
                    "algorithm": ref.read(editItemProvider).algorithm,
                    "digits": digitsTextController.text,
                    "period": periodTextController.text,
                  });
              var box = Hive.box<Token>("2fa");
              if (labelTextController.text.isEmpty) {
                showErrorToast(context, "名称为必填项目");
                return;
              } else if (secrectTextController.text.isEmpty) {
                showErrorToast(context, "密钥为必填项目");
                return;
              }
              Token t = Token(
                  scheme: ref.read(editItemProvider).scheme,
                  label: labelTextController.text,
                  issuer: issuerTextController.text,
                  secret: secrectTextController.text,
                  algorithm: editItem.algorithm,
                  otpauth: uri.toString(),
                  period: int.parse(periodTextController.text),
                  digits: int.parse(digitsTextController.text),
                  uuid: uuidVal.value,
                  count: int.tryParse(countTextController.text));

              box.put(uuidVal.value, t);
              ref.read(tokenItemsProvider.notifier).update();
              ref.read(pageProvider.notifier).update((state) => 0);
            },
          )
        ],
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: [
                        const Text("链接"),
                        const SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          controller: uriTextController,
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
                      children: [
                        const Text("服务商"),
                        const SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          controller: issuerTextController,
                          placeholder: '设置服务商',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: [
                        const Text("名称"),
                        const SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          controller: labelTextController,
                          placeholder: '名称',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: [
                        const Text("密钥"),
                        const SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                          ],
                          controller: secrectTextController,
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
                      const Text("类型"),
                      const SizedBox(
                        width: 14,
                      ),
                      MacosPopupButton<String>(
                        value: editItem.scheme,
                        onChanged: (String? newValue) {
                          ref.read(editItemProvider.notifier).setScheme(newValue!);
                        },
                        items: <String>[
                          'TOTP',
                          'HOTP',
                        ].map<MacosPopupMenuItem<String>>((String value) {
                          return MacosPopupMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      const Text("算法"),
                      const SizedBox(
                        width: 14,
                      ),
                      MacosPopupButton<String>(
                        value: editItem.algorithm,
                        onChanged: (String? newValue) {
                          ref.read(editItemProvider.notifier).setAlgorithm(newValue!);
                        },
                        items: <String>['SHA1', 'SHA256', 'SHA512'].map<MacosPopupMenuItem<String>>((String value) {
                          return MacosPopupMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                    ]),
                  ),
                  editItem.scheme == "TOTP"
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          // color: Colors.amber,
                          child: Row(
                            children: [
                              const Text("时间"),
                              const SizedBox(
                                width: 14,
                              ),
                              Flexible(
                                  child: MacosTextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, //数字，只能是整数
                                ],
                                controller: periodTextController,
                                placeholder: '时间间隔',
                              ))
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          // color: Colors.amber,
                          child: Row(
                            children: [
                              const Text("计数器"),
                              const SizedBox(
                                width: 14,
                              ),
                              Flexible(
                                  child: MacosTextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, //数字，只能是整数
                                ],
                                controller: countTextController,
                                placeholder: '设定计数器',
                              ))
                            ],
                          ),
                        ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    // color: Colors.amber,
                    child: Row(
                      children: [
                        const Text("位数"),
                        const SizedBox(
                          width: 14,
                        ),
                        Flexible(
                            child: MacosTextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, //数字，只能是整数
                          ],
                          controller: digitsTextController,
                          placeholder: '位数',
                        ))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 16,
                    color: Colors.grey[100],
                  ),
                  Flexible(
                      child: DropTarget(
                          onDragDone: (detail) async {
                            for (var element in detail.files) {
                              final mimeType = lookupMimeType(element.path);
                              Log.d(lookupMimeType(element.path), "file");
                              if (mimeType != null && mimeType.contains("image")) {
                                String? text = await QrUtil.decodeText(element, context);
                                if (text != null) uriTextController.text = text;
                              }
                            }
                          },
                          onDragEntered: (detail) {
                            ref.read(dragProvider.notifier).update((state) => true);
                          },
                          onDragExited: (detail) {
                            ref.read(dragProvider.notifier).update((state) => false);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: SizedBox(
                                  height: 160,
                                  width: 160,
                                  child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          Color(isDragging ? 0xff2196f3 : 0xffbdbdbd), BlendMode.srcATop),
                                      child: Image.asset("assets/img/scan_qr.png")),
                                ),
                                onTap: () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                                  Log.d(result, "xxx");
                                  if (result != null) {
                                    File file = File(result.files.single.path!);
                                    String? text = await QrUtil.decodeText(file, context);
                                    if (text != null) {
                                      uriTextController.text = text;
                                    }
                                  } else {
                                    // User canceled the picker
                                    // showErrorToast(context, "文件未被选择");
                                  }
                                },
                              ),
                              Semantics(
                                onPaste: () {
                                  Log.d("onPaste");
                                },
                                child: Text("拖拽或点击以选择文件导入",
                                    style: TextStyle(
                                      color: Color(isDragging ? 0xff2196f3 : 0xffbdbdbd),
                                    )),
                              ),
                              const SizedBox(
                                height: 72,
                              ),
                            ],
                          )))
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
