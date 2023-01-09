import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/vehicle_information.dart';
import 'package:laudo_eletronico/presentation/nova_vistoria/nova_vistoria_controller.dart';

abstract class NovaVistoriaViewContract {
  showAlertConfirmCarPlate(String carPlate);
  notifyDataChanged();
  navigatorPush(MaterialPageRoute route);
  setFocusCarPlateTextField();
}

abstract class NovaVistoriaPresenterContract {
  bool showIndeterminateProgress;
  bool isInformationsLoaded;
  bool canGoNextStep;
  bool get isAgendado;
  
  VehicleInformations get vehicleInformations;
  NovaVistoriaController get controller;

  onTextFieldCarPlateChanged(String text);
  btnNexStepClickListener();
  pushNextStep();
  clearCarPlateField();
}