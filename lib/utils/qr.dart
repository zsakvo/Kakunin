// ignore_for_file: use_build_context_synchronously

import 'package:flutter/widgets.dart';
import 'package:qr_code_vision/qr_code_vision.dart';
import 'dart:ui' as ui;

import 'flash.dart';

class QrUtil {
  static final qrCode = QrCode();
  static Future<String?> decodeText(dynamic file, BuildContext context) async {
    var byteData = await file.readAsBytes();
    var codec = await ui.instantiateImageCodec(byteData);
    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image image = fi.image;
    var bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    qrCode.scanRgbaBytes(bytes, image.width, image.height);
    if (qrCode.location == null) {
      showErrorToast(context, "图片中没有找到二维码");
    } else {
      if (qrCode.content == null) {
        showErrorToast(context, "二维码解析失败");
      } else {
        // showSuccessToast(context, qrCode.content!.text);
        return qrCode.content!.text;
      }
    }
    return null;
  }
}
