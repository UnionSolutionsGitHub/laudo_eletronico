import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../login_contract.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';


class LoginViewPassword extends StatefulWidget {
  final LoginPresenterContract presenter;

  LoginViewPassword(this.presenter);

  @override
  _LoginViewPasswordState createState() => _LoginViewPasswordState();
}

class _LoginViewPasswordState extends State<LoginViewPassword> {
  bool visualizarSenha = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
      child: TextField(
          keyboardType: TextInputType.text,
          obscureText: visualizarSenha,
          controller: this.widget.presenter.edtxControllerPassword,
          focusNode: this.widget.presenter.edtxFocusNodePassword,
          onSubmitted: (s) {
            this.widget.presenter.doLogin();
          },
          decoration: new InputDecoration(
            labelText: GlobalizationStrings.of(context).value("login_password_textfield_placeholder"),
            prefixIcon: Icon(MdiIcons.keyVariant),
            suffixIcon: MaterialButton(
              height: 30.0,
              minWidth: 35.0,
              padding: EdgeInsets.all(0.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Icon(
                visualizarSenha ? MdiIcons.eyeOff : MdiIcons.eye,
                size: 24.0,
                color: AppColors.gray,
              ),
              onPressed: () {
                setState(() {
                  visualizarSenha = !visualizarSenha;
                });
              },
            ),
          ),
        ),
    );
  }
}
