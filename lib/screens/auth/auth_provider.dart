import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp/data/entity/totp.dart';

class TotpItem {
  final Totp totp;
  final AnimationController? controller;
  final Color backgroundColor;
  int leftTime;

  TotpItem({required this.totp, this.controller, required this.backgroundColor, this.leftTime = 30});
  // final
}

class TotpItemsNotifier extends StateNotifier<List<TotpItem>> {
  TotpItemsNotifier()
      : super([
          TotpItem(
              totp: Totp.fromMap(const {"secret": "23334", "label": "zsakvo", "issuer": "Google", "digits": 6}),
              // controller: controller,
              backgroundColor: Colors.blue[100]!)
        ]);
}

final totpItemsProvider = StateNotifierProvider<TotpItemsNotifier, List<TotpItem>>((ref) {
  return TotpItemsNotifier();
});

class LeftTimeNotifier extends StateNotifier<double> {
  // We initialize the list of todos to an empty list
  LeftTimeNotifier() : super(1.0) {
    setTime();
  }

  void setTime() {
    const period = Duration(seconds: 1);
    Timer.periodic(period, (timer) {
      if (state > (1 / 30)) {
        state -= 1 / 30;
      } else {
        state = 1.0;
      }
    });
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final leftTimeProvider = StateNotifierProvider<LeftTimeNotifier, double>((ref) {
  return LeftTimeNotifier();
});
