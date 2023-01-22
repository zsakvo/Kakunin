import 'dart:async';

import 'package:flutter/material.dart' hide MenuItem;

import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:otp/otp.dart';
import 'package:kakunin/data/entity/token.dart';

import 'package:timezone/timezone.dart' as timezone;

final pacificTimeZone = timezone.getLocation('America/Los_Angeles');
final box = Hive.box<Token>("2fa");

class TokenItem {
  Token token;
  final AnimationController? controller;
  // final Color backgroundColor;
  double leftTime;
  String currentCode;
  double timeValue;

  TokenItem(
      {required this.token, this.controller, this.leftTime = 30, this.timeValue = 100.0, this.currentCode = "------"});
  void setToken(Token t) {
    token = t;
  }
}

class TokenItemsNotifier extends StateNotifier<List<TokenItem>> {
  TokenItemsNotifier() : super([]) {
    update();
  }

  update() {
    Box<Token> box = Hive.box("2fa");
    state = [
      ...box.values
          .toList()
          .map((e) => TokenItem(
                token: e,
              ))
          .toList()
    ];

    state = state.map((tokenItem) {
      Token token = tokenItem.token;
      late Algorithm algorithm;
      if (token.algorithm == "SHA1") {
        algorithm = Algorithm.SHA1;
      } else if (token.algorithm == "SHA256") {
        algorithm = Algorithm.SHA256;
      } else if (token.algorithm == "SHA512") {
        algorithm = algorithm = Algorithm.SHA512;
      }

      final now = DateTime.now();
      final date = timezone.TZDateTime.from(now, pacificTimeZone);

      late final String code;
      if (token.scheme == "TOTP") {
        code = OTP.generateTOTPCodeString(tokenItem.token.secret!, date.millisecondsSinceEpoch,
            algorithm: algorithm, isGoogle: true);
      } else {
        code = OTP.generateHOTPCodeString(tokenItem.token.secret!, tokenItem.token.count!, isGoogle: true);
      }
      final leftTime = OTP.remainingSeconds(interval: token.period!) * 1.0;
      final timeValue = 100.0 * (leftTime / token.period!);
      return TokenItem(token: token, currentCode: code, leftTime: leftTime, timeValue: timeValue);
    }).toList();
  }

  remove(Token token) {
    state = state.where((element) => element.token != token).toList();
  }

  chronometer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var i = 0; i < state.length; i++) {
        TokenItem tokenItem = state[i];
        Token token = tokenItem.token;
        if (token.scheme == "TOTP") {
          late Algorithm algorithm;
          if (token.algorithm == "SHA1") {
            algorithm = Algorithm.SHA1;
          } else if (token.algorithm == "SHA256") {
            algorithm = Algorithm.SHA256;
          } else if (token.algorithm == "SHA512") {
            algorithm = algorithm = Algorithm.SHA512;
          }
          // final num = 100 * 1 / token.period!;
          double leftTime;
          String currentCode;
          double timeValue;
          if (tokenItem.leftTime > 1) {
            leftTime = tokenItem.leftTime - 1;
            currentCode = tokenItem.currentCode;
          } else {
            leftTime = token.period! - (1 - tokenItem.leftTime);
            final now = DateTime.now();
            final date = timezone.TZDateTime.from(now, pacificTimeZone);
            currentCode = OTP.generateTOTPCodeString(token.secret!, date.millisecondsSinceEpoch,
                algorithm: algorithm, isGoogle: true);
          }

          timeValue = (leftTime / token.period!) * 100.0;

          state[i] = TokenItem(token: token, leftTime: leftTime, currentCode: currentCode, timeValue: timeValue);
        } else {
          state[i] = tokenItem;
        }
      }
      state = [...state];
      // timer.cancel();
    });
  }

  updateHotp(TokenItem item) {
    int index = state.indexOf(item);
    var code = OTP.generateHOTPCodeString(item.token.secret!, item.token.count! + 1, isGoogle: true);
    var token = item.token.copyWith(count: item.token.count! + 1);
    var newItem = TokenItem(token: token, currentCode: code);
    state[index] = newItem;
    box.put(item.token.uuid, token);
  }
}

final tokenItemsProvider = StateNotifierProvider<TokenItemsNotifier, List<TokenItem>>((ref) {
  return TokenItemsNotifier();
});

final editorProvider = StateProvider<bool>(((ref) => false));

// final editItemProvider = StateProvider<Token?>(
//   (ref) => null,
// );

class EditItemNotifier extends StateNotifier<Token> {
  // We initialize the list of todos to an empty list
  EditItemNotifier()
      : super(Token.fromMap(const {"algorithm": "SHA1", "scheme": "TOTP", "secret": "", "digits": 6, "period": 30}));

  void setBlank() {
    state = Token.fromMap(const {"algorithm": "SHA1", "scheme": "TOTP", "secret": "", "digits": 6, "period": 30});
  }

  void setState(Token token) {
    state = token;
  }

  void setOtpAuth(String s) {
    state = state.copyWith(otpauth: s);
  }

  void setIssuer(String s) {
    state = state.copyWith(issuer: s);
  }

  void setLabel(String s) {
    state = state.copyWith(label: s);
  }

  void setSecret(String s) {
    state = state.copyWith(secret: s);
  }

  void setScheme(String s) {
    state = state.copyWith(scheme: s);
  }

  void setAlgorithm(String s) {
    state = state.copyWith(algorithm: s);
  }

  void setPeriod(int i) {
    state = state.copyWith(period: i);
  }

  void setDigits(int i) {
    state = state.copyWith(digits: i);
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final editItemProvider = StateNotifierProvider<EditItemNotifier, Token>((ref) {
  return EditItemNotifier();
});
