import 'package:flutter/material.dart';

class LoginViewHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 30.0),
      alignment: Alignment.topCenter,
      child: Image.asset(
        "./assets/images/logo_white.png",
        width: 200.0,
      ),
    );
  }
}
