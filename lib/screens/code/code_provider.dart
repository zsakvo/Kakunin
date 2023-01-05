import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:totp/data/entity/totp.dart';
import 'package:totp/screens/auth/auth_provider.dart';

class CodeEditorNotifier extends StateNotifier<TotpItem> {
  // We initialize the list of todos to an empty list
  CodeEditorNotifier()
      : super(TotpItem(
            totp: Totp.fromMap(const {"algorithm": "SHA1", "scheme": "TOTP", "secret": "", "digits": 6, "period": 30}),
            backgroundColor: Colors.blue)) {
    setTime();
  }

  void setTime() {}
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final codeEditorProvider = StateNotifierProvider<CodeEditorNotifier, TotpItem>((ref) {
  return CodeEditorNotifier();
});
