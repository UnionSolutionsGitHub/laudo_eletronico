import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laudo_eletronico/common/uppercase_text_formatter.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../nova_vistoria_contract.dart';

class NovaVistoriaViewDescricaoVeiculo extends StatelessWidget {
  final NovaVistoriaPresenterContract _presenter;

  NovaVistoriaViewDescricaoVeiculo(this._presenter);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildHeader(context),
          _buildForm(context),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Expanded(
      child: Container(
        child: Center(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  //txfdCarPlate
                  margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: TextField(
                    enabled: _presenter.controller.txfdCarPlateEnabled,
                    textInputAction: TextInputAction.next,
                    focusNode: _presenter.controller.txfdCarPlateFocusNode,
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: new InputDecoration(
                      prefixIcon: Icon(MdiIcons.car),
                      labelText: GlobalizationStrings.of(context)
                          .value("nova_vistoria_edtx_placa_title"),
                    ),
                    onChanged: _presenter.onTextFieldCarPlateChanged,
                    controller: _presenter.controller.txfdCarPlateController,
                  ),
                ),
                _presenter.showIndeterminateProgress &&
                        !_presenter.isInformationsLoaded
                    ? Container(
                        margin: EdgeInsets.all(50),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                _presenter.isInformationsLoaded
                    ? Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: ListTile(
                          leading: Container(
                            width: 70.0,
                            height: 70.0,
                            child: Image.asset(
                              "./assets/images/marcas/${_presenter.vehicleInformations?.modelLogoName ?? ""}.png",
                            ),
                          ),
                          title: Text(
                            "${_presenter.vehicleInformations?.marca ?? ""} ${_presenter.vehicleInformations?.modelo ?? ""}",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17.0,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _presenter?.vehicleInformations?.cor ?? "",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                "${_presenter.vehicleInformations?.anoFababricacao ?? ""}/${_presenter.vehicleInformations?.anoModelo ?? ""}",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        GlobalizationStrings.of(context).value("nova_vistoria_descripton"),
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
