import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:flutter/services.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';

import './splash_screen_contract.dart';
import './splash_screen_presenter.dart';

class SplashScreenView extends StatefulWidget {
  @override
  _SplashScreenViewState createState() {
    return new _SplashScreenViewState();
  }
}

class _SplashScreenViewState extends State<SplashScreenView> implements SplashScreenViewContract {
  //SplashScreenPresenterContract _presenter;

  _SplashScreenViewState() {
    //_presenter = SplashScreenPresenter(this, UnionSolutionsService());
    SplashScreenPresenter(this, UnionSolutionsService());
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: FractionalOffset.topLeft,
                      end: FractionalOffset.bottomRight,
                      colors: [
                        AppColors.primary,
                        Color.fromRGBO(0, 33, 71, 1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                child: Image.asset(
                  "./assets/images/logo_white.png",
                  width: 200.0,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    GlobalizationStrings.of(context).value("main_title"),
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text(
                  GlobalizationStrings.of(context).value("copyright"),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Future navigatorPushReplacementNamed(String route) async {
    final result = await Navigator.of(context).pushReplacementNamed(route);
    return result;
  }

  @override
  Future navigatorPushNamed(String route) async {
    final result = await Navigator.of(context).pushNamed(route);
    return result;
  }

  @override
  void showErrorMessage(String errorMessage) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            GlobalizationStrings.of(context).value("alert_title_warning"),
          ),
          content: new Text(
            GlobalizationStrings.of(context).value(errorMessage),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                GlobalizationStrings.of(context).value("alert_button_ok"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void navigatorPush(MaterialPageRoute route) {
    Navigator.pushReplacement(context, route);
  }
}
