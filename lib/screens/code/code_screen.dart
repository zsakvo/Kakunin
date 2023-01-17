import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:totp/data/entity/totp.dart';
import 'package:totp/screens/auth/auth_provider.dart';
import 'package:totp/screens/code/code_provider.dart';
import 'package:totp/utils/log.dart';

class CodeScreen extends StatefulHookConsumerWidget {
  const CodeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  @override
  Widget build(BuildContext context) {
    final Totp totp = ref.watch(codeEditorProvider);
    final uriTextController = useTextEditingController();
    final issuerTextController = useTextEditingController();
    final labelTextController = useTextEditingController();
    final secrectTextController = useTextEditingController();
    final periodTextController = useTextEditingController();
    final digitsTextController = useTextEditingController();

    // periodTextController.text = totp.period.toString();
    // digitsTextController.text = totp.digits.toString();

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
      periodTextController.text = period;
      // ref.read(codeEditorProvider.notifier).setPeriod(int.tryParse(period) ?? 30);
      // ref.read(codeEditorProvider.notifier).setDigits(int.tryParse(digits) ?? 6);
      digitsTextController.text = digits;

      if (scheme.isNotEmpty) {
        if (!["TOTP", "HOTP"].contains(scheme)) {
          Log.d("当前类型不被支持");
        } else {
          ref.read(codeEditorProvider.notifier).setScheme(scheme);
        }
      }
      if (!["SHA1", "SHA256", "SHA512"].contains(algorithm)) {
        Log.d("当前算法不被支持");
      } else {
        ref.read(codeEditorProvider.notifier).setAlgorithm(algorithm);
      }
    }

    totpItemTextValueListener(String key, String value) {
      // Log.d(value, key);
      // Uri uri = Uri(scheme: "otpauth", host: totp.scheme, queryParameters: {key: value});
      // Uri uri = Uri.parse(uriTextController.text);
      // uri.replace(scheme: totp.scheme).replace(host: totp.scheme);
      // uri = uri.replace(queryParameters: {...uri.queryParameters, key: value}, scheme: "otpauth", host: totp.scheme);
      // uriTextController.text = uri.toString();
    }

    issuerListener() => totpItemTextValueListener("issuer", issuerTextController.text);
    labelListener() => totpItemTextValueListener("label", labelTextController.text);
    secrectListener() => totpItemTextValueListener("secrect", secrectTextController.text);
    periodListener() => totpItemTextValueListener("period", periodTextController.text);
    digitsListenr() => totpItemTextValueListener("digits", digitsTextController.text);

    useEffect(() {
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
        title: const Text("新增凭证"),
        actions: [
          ToolBarIconButton(
            label: "保存",
            icon: const MacosIcon(CupertinoIcons.arrow_down_doc),
            showLabel: false,
            onPressed: () {
              // print("click");
              var box = Hive.box<Totp>("2fa");
              Totp t = Totp(
                  scheme: "otpauth",
                  label: labelTextController.text,
                  issuer: issuerTextController.text,
                  secret: secrectTextController.text,
                  algorithm: totp.algorithm,
                  period: int.parse(periodTextController.text),
                  digits: int.parse(digitsTextController.text));
              box.put(labelTextController.text, t);
            },
          )
        ],
        leading: MacosBackButton(
          fillColor: Colors.transparent,
          onPressed: () {},
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
                        value: totp.scheme,
                        onChanged: (String? newValue) {
                          ref.read(codeEditorProvider.notifier).setScheme(newValue!);
                          // setState(() {
                          //   totpItem.setTotp(totpItem.totp.copyWith(scheme: newValue));
                          // });
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
                        value: totp.algorithm,
                        onChanged: (String? newValue) {
                          ref.read(codeEditorProvider.notifier).setAlgorithm(newValue!);
                          // setState(() {
                          //   totpItem.setTotp(totpItem.totp.copyWith(algorithm: newValue));
                          // });
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
                  Container(
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
                          controller: periodTextController,
                          placeholder: '时间间隔',
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
                          controller: digitsTextController,
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
