import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_controller.dart';

abstract class LaudoChecklistAlertListViewContract {
  notifyDataChanged();
  popWithResult(LaudoOption alert);
}

abstract class LaudoChecklistAlertListPresenterContract {
  LaudoChecklistAlertListController get controller;
  List<LaudoOption> get alerts;

  onSearchBarQUeryChanged(String query);
  onSelectedItemListener(int index);
  Color colorFor(int index);
  IconData iconFor(int index);
}