import 'package:flutter/material.dart';

import './login_contract.dart';
import './login_presenter.dart';
import './widgets/login_view_background.dart';
import './widgets/login_view_header.dart';
import './widgets/login_view_credential_container.dart';
import './widgets/login_view_footer.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';

class LoginView extends StatefulWidget {
  @override
  LoginViewState createState() {
    return LoginViewState();
  }
}

class LoginViewState extends State<LoginView> implements LoginViewContract {
  BuildContext _context;
  LoginPresenterContract _presenter;

  LoginViewState() {
    _presenter = LoginPresenter(this, UnionSolutionsService());
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;

    return Scaffold(
      body: Stack(
        children: [
          LoginViewBackground(),
          LoginViewFooter(this._presenter),
          LoginViewHeader(),
          LoginViewCredentialContainer(this._presenter),
        ],
      ),
    );
  }

  @override
  void showErrorMessage(String errorMessage) {
    showDialog(
      context: this._context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(GlobalizationStrings.of(this._context)
              .value("alert_title_warning")),
          content:
              Text(GlobalizationStrings.of(this._context).value(errorMessage)),
          actions: <Widget>[
            FlatButton(
              child: Text(GlobalizationStrings.of(this._context)
                  .value("alert_button_ok")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void navigatorPushReplacementNamed(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void navigatorPushReplacement(MaterialPageRoute route) {
    Navigator.pushReplacement(context, route);
  }

  @override
  navigatorPushNamed(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  showProgressIndeterminate() {
    showDialog(
      context: this._context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this._context).value("login_alert_progress_title"),
          ),
          content: Container(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  @override
  hideProgressIndeterminate() {
    Navigator.of(context).pop();
  }
}
