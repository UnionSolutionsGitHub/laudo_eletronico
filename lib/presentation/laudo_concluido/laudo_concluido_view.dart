import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_presenter.dart';
import 'package:laudo_eletronico/presentation/nova_vistoria/nova_vistoria_view.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/vistorias_pendentes_view.dart';
import 'package:screen/screen.dart';

class LaudoConcluidoView extends StatefulWidget {
  final _laudo;

  LaudoConcluidoView(this._laudo);

  @override
  _LaudoConcluidoViewState createState() => _LaudoConcluidoViewState();
}

class _LaudoConcluidoViewState extends State<LaudoConcluidoView>
    implements LaudoConcluidoViewContract {
  LaudoConcluidoPresenterContract _presenter;

  @override
  void initState() {
    Screen.keepOn(true);
    _presenter = LaudoConcluidoPresenter(this, this.widget._laudo);
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    Screen.keepOn(false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Container(
          width: 300,
          height: 350,
          child: Card(
            elevation: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(15),
                  child: Text(
                    _presenter.mensage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _presenter.isSyncing
                        ? CircularProgressIndicator()
                        : Column(
                            children: <Widget>[
                              Expanded(
                                child: Center(
                                  child: Text(
                                    GlobalizationStrings.of(this.context).value(
                                        "laudo_concluido_bttn_concluido"),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: RaisedButton(
                                        child: Text(
                                          GlobalizationStrings.of(this.context)
                                              .value("alert_button_ok"),
                                        ),
                                        onPressed: _presenter.isSyncing
                                            ? null
                                            : _presenter.checkRedirectToView,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  notifyDataChanged() {
    this.setState(() {});
  }

  @override
  showErrorMessage(
      {String erroMessage = "laudo_concluido_alert_erro_message"}) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("alert_title_warning"),
          ),
          content: Text(
            GlobalizationStrings.of(this.context).value(erroMessage),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("alert_button_ok"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _presenter.checkRedirectToView();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  navigateToPendentes() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => VistoriasPendentesView(
              configMenu:
                  ConfigurationMenuButton(),
            ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  naviteToNovaVistoria() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => NovaVistoriaView(
              configMenu:
                  ConfigurationMenuButton(),
            ),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
