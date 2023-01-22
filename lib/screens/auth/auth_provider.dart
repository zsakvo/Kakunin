import 'dart:async';

import 'package:flutter/material.dart' hide MenuItem;

import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp/otp.dart';
import 'package:totp/data/entity/totp.dart';

import 'package:timezone/timezone.dart' as timezone;

final pacificTimeZone = timezone.getLocation('America/Los_Angeles');
final box = Hive.box<Totp>("2fa");

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

      final now = DateTime.now();
      final date = timezone.TZDateTime.from(now, pacificTimeZone);
      // Log.d({"secrect": totpItem.totp.secret, "time": date.millisecondsSinceEpoch, "algorithm": algorithm});

      late final String code;
      if (totp.scheme == "TOTP") {
        code = OTP.generateTOTPCodeString(totpItem.totp.secret!, date.millisecondsSinceEpoch,
            algorithm: algorithm, isGoogle: true);
      } else {
        code = OTP.generateHOTPCodeString(totpItem.totp.secret!, totpItem.totp.count!, isGoogle: true);
      }
      final leftTime = OTP.remainingSeconds(interval: totp.period!) * 1.0;
      final timeValue = 100.0 * (leftTime / totp.period!);
      return TotpItem(totp: totp, currentCode: code, leftTime: leftTime, timeValue: timeValue);
    }).toList();
  }

  remove(Totp totp) {
    state = state.where((element) => element.totp != totp).toList();
  }

  chronometer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var i = 0; i < state.length; i++) {
        TotpItem totpItem = state[i];
        Totp totp = totpItem.totp;
        if (totp.scheme == "TOTP") {
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
          if (totpItem.leftTime > 1) {
            leftTime = totpItem.leftTime - 1;
            currentCode = totpItem.currentCode;
          } else {
            leftTime = totp.period! - (1 - totpItem.leftTime);
            final now = DateTime.now();
            final date = timezone.TZDateTime.from(now, pacificTimeZone);
            currentCode = OTP.generateTOTPCodeString(totp.secret!, date.millisecondsSinceEpoch,
                algorithm: algorithm, isGoogle: true);
          }
          // Log.d(leftTime, "num");
          timeValue = (leftTime / totp.period!) * 100.0;
          // stateX.add(TotpItem(totp: totp, leftTime: leftTime, currentCode: currentCode, timeValue: timeValue));
          // Log.d(TotpItem(totp: totp, leftTime: leftTime, currentCode: currentCode, timeValue: timeValue) == state[i],
          //     "ppp");
          state[i] = TotpItem(totp: totp, leftTime: leftTime, currentCode: currentCode, timeValue: timeValue);
        } else {
          // stateX.add(totpItem);
          state[i] = totpItem;
        }
        // stateX.add(totpItem);
      }
      state = [...state];
      // timer.cancel();
    });
  }

  updateHotp(TotpItem item) {
    int index = state.indexOf(item);
    var code = OTP.generateHOTPCodeString(item.totp.secret!, item.totp.count! + 1, isGoogle: true);
    var totp = item.totp.copyWith(count: item.totp.count! + 1);
    var newItem = TotpItem(totp: totp, currentCode: code);
    state[index] = newItem;
    box.put(item.totp.uuid, totp);
  }
}

final totpItemsProvider = StateNotifierProvider<TotpItemsNotifier, List<TotpItem>>((ref) {
  return TotpItemsNotifier();
});

final editorProvider = StateProvider<bool>(((ref) => false));

final editItemProvider = StateProvider<Totp?>(
  (ref) => null,
);
