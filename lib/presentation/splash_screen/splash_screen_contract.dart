import 'package:flutter/material.dart';

abstract class SplashScreenViewContract {
  void navigatorPush(MaterialPageRoute route);
  Future navigatorPushReplacementNamed(String route);
  Future navigatorPushNamed(String route);
  void showErrorMessage(String errorMessage);
}

abstract class SplashScreenPresenterContract {
}