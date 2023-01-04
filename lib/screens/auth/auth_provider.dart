import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp/data/entity/totp.dart';

class TotpItem {
  final Totp totp;
  final AnimationController? controller;
  final Color backgroundColor;
  int leftTime;
  String currentCode;

  TotpItem(
      {required this.totp,
      this.controller,
      required this.backgroundColor,
      this.leftTime = 30,
      this.currentCode = "------"}) {
    leftTime = totp.period ?? 30;
    final ts = DateTime.now().millisecondsSinceEpoch;
    currentCode = OTP.generateTOTPCodeString(
      totp.secret!,
      ts,
    );
    setTime();
  }

  void setTime() {
    const period = Duration(seconds: 30);
    Timer.periodic(period, (timer) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      print(ts);
      currentCode = OTP.generateTOTPCodeString(
        totp.secret!,
        ts,
        algorithm: Algorithm.SHA1,
      );
    });
  }
  // final
}

class TotpItemsNotifier extends StateNotifier<List<TotpItem>> {
  TotpItemsNotifier()
      : super([
          TotpItem(
              totp: Totp.fromMap(const {"secret": "23334", "label": "zsakvo", "issuer": "Google", "digits": 6}),
              // controller: controller,
              backgroundColor: Colors.blue[100]!),
          TotpItem(
              totp: Totp.fromMap(const {"secret": "23333", "label": "zsakvo", "issuer": "Google", "digits": 6}),
              // controller: controller,
              backgroundColor: Colors.blue[100]!),
          TotpItem(
              totp: Totp.fromMap(const {"secret": "23333", "label": "zsakvo", "issuer": "Google", "digits": 6}),
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

////////
///
///
///

class AnimatedLiquidCircularProgressIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AnimatedLiquidCircularProgressIndicatorState();
}

class AnimatedLiquidCircularProgressIndicatorState extends State<AnimatedLiquidCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 36.0,
        height: 36.0,
        child: LiquidCircularProgressIndicator(
          value: _animationController.value,
          backgroundColor: Colors.blue[100],
          valueColor: const AlwaysStoppedAnimation(Colors.blue),
        ),
      ),
    );
  }
}
