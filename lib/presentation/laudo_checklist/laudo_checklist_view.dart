import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_presenter.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/widgets/laudo_checklist_list_builder.dart';
import 'package:laudo_eletronico/presentation/laudo_observacoes/laudo_observacoes_view.dart';

class LaudoChecklistView extends StatefulWidget {
  final Laudo _laudo;
  final String _type;

  LaudoChecklistView(this._laudo, this._type);

  @override
  _LaudoChecklistViewState createState() => _LaudoChecklistViewState();
}

class _LaudoChecklistViewState extends State<LaudoChecklistView> implements LaudoChecklistViewContract {
  LaudoChecklistPresenterContract _presenter;

  @override
  void initState() {
    _presenter = LaudoChecklistPresenter(this, this.widget._laudo, this.widget._type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          GlobalizationStrings.of(context).value(_presenter.appBarTitleStringKey),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => LaudoObservacoesView(_presenter.laudoType, _presenter.laudoId)));
            },
          ),
        ],
      ),
      body: _presenter.isLoading
          ? CircularProgressIndicator()
          : Column(
              children: <Widget>[
                Expanded(
                  child: LaudoChecklistListBuilder(_presenter),
                ),
              ],
            ),
    );
  }

  @override
  navigatorPush(MaterialPageRoute route) {
    Navigator.push(context, route);
  }

  @override
  Future<LaudoOption> navigatorPushAwaitForResult(Widget route) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => route,
      ),
    );

    return result;
  }

  @override
  notifyDataChanged() {
    this.setState(() {});
  }

  @override
  showAlertCantGoNextStep() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("alert_title_warning"),
          ),
          content: Text(
            GlobalizationStrings.of(this.context).value("laudo_checklist_alert_cant_go_next_step"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("alert_button_ok"),
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
}
