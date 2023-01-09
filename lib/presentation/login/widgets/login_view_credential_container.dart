import 'package:flutter/material.dart';

import './login_view_password.dart';
import '../login_contract.dart';
import '../../../infrastructure/resources/globalization_strings.dart';
import '../../../infrastructure/resources/colors.dart';

class LoginViewCredentialContainer extends StatelessWidget {
  final LoginPresenterContract _presenter;

  LoginViewCredentialContainer(this._presenter);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 3.0)],
          color: Colors.white,
        ),
        alignment: Alignment.center,
        margin: EdgeInsets.all(20.0),
        padding: EdgeInsets.all(20.0),
        height: 290.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              GlobalizationStrings.of(context).value("login_container_title"),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              height: 50.0,
              margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 30.0),
              child: TextField(
                textInputAction: TextInputAction.next,
                focusNode: this._presenter.edtxFocusNodeUser,
                onSubmitted: (s) {
                  this._presenter.edtxFocusNodeUser.unfocus();
                  FocusScope.of(context).requestFocus(this._presenter.edtxFocusNodePassword);
                },
                controller: this._presenter.edtxControllerUsername,
                decoration: new InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: GlobalizationStrings.of(context).value("login_username_textfield_placeholder"),
                ),
              ),
            ),
            LoginViewPassword(this._presenter),
            RaisedButton(
              child: Text(
                GlobalizationStrings.of(context).value("login_btn_entrar"),
              ),
              onPressed: () {
                this._presenter.doLogin();
              },
            ),
          ],
        ),
      ),
    );
  }
}
