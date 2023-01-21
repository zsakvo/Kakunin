import 'dart:async';

import 'package:flutter/material.dart' hide MenuItem;
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp/otp.dart';
import 'package:totp/data/entity/totp.dart';

class TotpItem {
  Totp totp;
  final AnimationController? controller;
  // final Color backgroundColor;
  double leftTime;
  String currentCode;
  double timeValue;

  TotpItem(
      {required this.totp, this.controller, this.leftTime = 30, this.timeValue = 100.0, this.currentCode = "------"});
  void setTotp(Totp t) {
    totp = t;
  }
}

class TotpItemsNotifier extends StateNotifier<List<TotpItem>> {
  final timers = [];
  late final Timer timer;
  TotpItemsNotifier() : super([]) {
    update();
  }

  update() {
    Box<Totp> box = Hive.box("2fa");
    state = [
      ...box.values
          .toList()
          .map((e) => TotpItem(
                totp: e,
              ))
          .toList()
    ];

    state = state.map((totpItem) {
      Totp totp = totpItem.totp;
      late Algorithm algorithm;
      if (totp.algorithm == "SHA1") {
        algorithm = Algorithm.SHA1;
      } else if (totp.algorithm == "SHA256") {
        algorithm = Algorithm.SHA256;
      } else if (totp.algorithm == "SHA512") {
        algorithm = algorithm = Algorithm.SHA512;
      }
      final ts = DateTime.now().millisecondsSinceEpoch;
      final code = OTP.generateTOTPCodeString(
        totpItem.totp.secret!,
        ts,
        algorithm: algorithm,
      );
      final leftTime = OTP.remainingSeconds(interval: totp.period!) * 1.0;
      final timeValue = 100.0 * (leftTime / totp.period!);
      return TotpItem(totp: totp, currentCode: code, leftTime: leftTime, timeValue: timeValue);
    }).toList();
  }

  remove(Totp totp) {
    state = state.where((element) => element.totp != totp).toList();
  }

  chronometer() {
    var d = 1;
    var period = Duration(seconds: d);
    timer = Timer.periodic(period, (timer) {
      var stateX = [];
      for (var i = 0; i < state.length; i++) {
        TotpItem totpItem = state[i];
        Totp totp = totpItem.totp;
        final ts = DateTime.now().millisecondsSinceEpoch;
        late Algorithm algorithm;
        if (totp.algorithm == "SHA1") {
          algorithm = Algorithm.SHA1;
        } else if (totp.algorithm == "SHA256") {
          algorithm = Algorithm.SHA256;
        } else if (totp.algorithm == "SHA512") {
          algorithm = algorithm = Algorithm.SHA512;
        }
        // final num = 100 * 1 / totp.period!;
        double leftTime;
        String currentCode;
        double timeValue;
        if (totpItem.leftTime > d) {
          leftTime = totpItem.leftTime - d;
          currentCode = totpItem.currentCode;
        } else {
          leftTime = totp.period! - (d - totpItem.leftTime);
          currentCode = OTP.generateTOTPCodeString(totp.secret!, ts, algorithm: algorithm);
        }
        timeValue = (leftTime / totp.period!) * 100.0;
        stateX.add(TotpItem(totp: totp, leftTime: leftTime, currentCode: currentCode, timeValue: timeValue));
      }
      state = [...stateX];
    });
  }
}

final totpItemsProvider = StateNotifierProvider<TotpItemsNotifier, List<TotpItem>>((ref) {
  return TotpItemsNotifier();
});

final editorProvider = StateProvider<bool>(((ref) => false));

final editItemProvider = StateProvider<Totp?>(
  (ref) => null,
);
