import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/model/vehicle_information.dart';
import 'package:laudo_eletronico/presentation/laudo_camera/laudo_camera_view.dart';
import 'package:laudo_eletronico/presentation/listagem_configuracoes/listagem_configuracoes_view.dart';
import 'package:laudo_eletronico/presentation/nova_vistoria/nova_vistoria_controller.dart';
import './nova_vistoria_contract.dart';

class NovaVistoriaPresenter implements NovaVistoriaPresenterContract {
  NovaVistoriaViewContract _view;
  Laudo _laudo;
  UnionSolutionsService _service;
  VehicleInformations _vehicleInformations;
  NovaVistoriaController _controller = NovaVistoriaController();

  NovaVistoriaPresenter(this._view, this._laudo, this._service) {
    _init();
  }

  _init() async {
    if (_laudo != null) {
      _controller.txfdCarPlateController.updateText(_laudo.carPlate);
      _controller.txfdCarPlateEnabled = _laudo.carPlate?.isNotEmpty != true;

      _getVehicleInformations(_laudo.carPlate);
    }
  }

  @override
  bool isInformationsLoaded = false;
  @override
  bool showIndeterminateProgress = false;
  @override
  bool canGoNextStep = false;
  @override
  VehicleInformations get vehicleInformations => _vehicleInformations;
  @override
  NovaVistoriaController get controller => _controller;
  @override
  bool get isAgendado => _laudo != null;

  onTextFieldCarPlateChanged(String text) {
    _controller.txfdCarPlateController.updateText(text);

    if (text.replaceAll("-", "").length < 7) {
      this.showIndeterminateProgress = false;
      this.isInformationsLoaded = false;
      this.canGoNextStep = false;
      _vehicleInformations = null;
      _view.notifyDataChanged();
      return;
    }
    _getVehicleInformations(text);
    _checkCanGoNextStep();
  }

  @override
  btnNexStepClickListener() {
    if (_vehicleInformations == null && _laudo == null) {
      _view.showAlertConfirmCarPlate(_controller.txfdCarPlateController.text);
      return;
    }

    this.pushNextStep();
  }

  @override
  pushNextStep() async {
    if (_laudo != null) {
      _laudo.date = DateTime.now();

      final laudoDao = LaudoDAO();
      laudoDao.update(_laudo);

      _view.navigatorPush(
        MaterialPageRoute(
          builder: (BuildContext context) => LaudoCameraView(_laudo, true),
        ),
      );

      return;
    }

    LocalResources localResources = await LocalResources().instance();

    final laudo = Laudo(
      user: User.fromToken(localResources.token),
      carPlate: _controller.txfdCarPlateController.text.replaceAll("-", ""),
      date: DateTime.now(),
      vehicleLogoName: _vehicleInformations?.modelLogoName ?? "ni",
      vehicleBrand: _vehicleInformations?.marca ?? "N/I",
      vehicleModel: _vehicleInformations?.modelo ?? "N/I",
      isPaintingDone: false,
      isPhotoDone: false,
      isStructureDone: false,
      isIdentifyDone: false,
      answers: List<Answer>(),
      additionalPhotos: List<AdditionalPhoto>(),
    );

    _view.navigatorPush(
      MaterialPageRoute(
        builder: (BuildContext context) => ListagemConfiguracoesView(laudo),
      ),
    );
  }

  _getVehicleInformations(String text) {
    this.showIndeterminateProgress = true;
    _view.notifyDataChanged();

    _service
        .getVehicleInformation(text)
        .then((VehicleInformations vehicleInformations) {
      _vehicleInformations = vehicleInformations;
      this.isInformationsLoaded = true;
      _view.notifyDataChanged();
    }).catchError((e) {
      this.showIndeterminateProgress = false;
      this.isInformationsLoaded = false;
      _view.notifyDataChanged();
    });
  }

  _checkCanGoNextStep() {
    this.canGoNextStep =
        (_controller.txfdCarPlateController.text?.isNotEmpty == true &&
            _controller.txfdCarPlateController.text.length >= 7);
    _view.notifyDataChanged();
  }

  @override
  clearCarPlateField() {
    _controller.txfdCarPlateController.text = "";
    this.canGoNextStep = false;
    _view.setFocusCarPlateTextField();
    this.isInformationsLoaded = false;
    _vehicleInformations = null;
  }
}
