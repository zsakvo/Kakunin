import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:totp/data/entity/totp.dart';

class CodeEditorNotifier extends StateNotifier<Totp> {
  // We initialize the list of todos to an empty list
  CodeEditorNotifier()
      : super(Totp.fromMap(const {"algorithm": "SHA1", "scheme": "TOTP", "secret": "", "digits": 6, "period": 30})) {
    setTime();
  }

  void setTime() {}

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
final codeEditorProvider = StateNotifierProvider<CodeEditorNotifier, Totp>((ref) {
  return CodeEditorNotifier();
});
