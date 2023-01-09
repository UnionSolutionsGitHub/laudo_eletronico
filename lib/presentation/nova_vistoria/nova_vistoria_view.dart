import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/search_text_result.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/laudo.dart';

import './nova_vistoria_contract.dart';
import './nova_vistoria_presenter.dart';
import './widgets/nova_vistoria_view_busca_veiculo.dart';

import 'package:laudo_eletronico/common/widgets/bottom_button.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';

class NovaVistoriaView extends StatefulWidget {
  final Widget configMenu;
  final Laudo laudo;

  NovaVistoriaView({
    @required this.configMenu,
    this.laudo,
  });

  @override
  _NovaVistoriaViewState createState() => _NovaVistoriaViewState();
}

class _NovaVistoriaViewState extends State<NovaVistoriaView>
    implements NovaVistoriaViewContract {
  NovaVistoriaPresenterContract _presenter;

  @override
  void initState() {
    this._presenter = NovaVistoriaPresenter(
        this, this.widget?.laudo, UnionSolutionsService());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          GlobalizationStrings.of(context).value("nova_vistoria_appbar_title"),
        ),
        actions: <Widget>[this.widget?.configMenu ?? Container()],
      ),
      backgroundColor: AppColors.light,
      body: Column(
        children: <Widget>[
          Expanded(
            child: NovaVistoriaViewDescricaoVeiculo(_presenter),
          ),
          BottomButton(
            stringsKey: "nova_vistoria_btn_next_step",
            onClick: _presenter.btnNexStepClickListener,
            isEnabled: _presenter.canGoNextStep,
          ),
        ],
      ),
    );
  }

  @override
  notifyDataChanged() {
    this.setState(() {});
  }

  @override
  showAlertConfirmCarPlate(String carPlate) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("alert_title_warning"),
          ),
          content: SearchTextResult(
            "$carPlate \n${GlobalizationStrings.of(this.context).value('nova_vistoria_confirm_carplate')}",
            carPlate,
            fontSize: 18,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context)
                    .value("nova_vistoria_alert_button_new_plate"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _presenter.clearCarPlateField();
              },
            ),
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context).value("alert_button_ok"),
              ),
              onPressed: () {
                _presenter.pushNextStep();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  navigatorPush(MaterialPageRoute route) {
    Navigator.push(context, route);
  }

  @override
  setFocusCarPlateTextField() {
    _presenter.controller
        .setFocus(context, _presenter.controller.txfdCarPlateFocusNode);
  }
}
