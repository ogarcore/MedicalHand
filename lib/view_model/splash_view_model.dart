import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> handleStartupLogic() async {
    await Future.delayed(const Duration(seconds: 3));

  }
}