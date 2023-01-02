import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      print(state);
    });
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final leftTimeProvider = StateNotifierProvider<LeftTimeNotifier, double>((ref) {
  return LeftTimeNotifier();
});
