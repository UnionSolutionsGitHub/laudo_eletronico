import 'package:flutter/material.dart';

abstract class LoginViewContract {
  showErrorMessage(String errorMessage);
  showProgressIndeterminate();
  hideProgressIndeterminate();
  navigatorPushReplacementNamed(String route);
  navigatorPushReplacement(MaterialPageRoute route);
  navigatorPushNamed(String route);
}

abstract class LoginPresenterContract {
  TextEditingController get edtxControllerUsername;
  TextEditingController get edtxControllerPassword;

  FocusNode get edtxFocusNodeUser;
  FocusNode get edtxFocusNodePassword;

  void doLogin();
}