import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LaudoChecklistAlertListPresenter
    implements LaudoChecklistAlertListPresenterContract {
  LaudoChecklistAlertListViewContract _view;
  List<LaudoOption> _alerts;
  LaudoChecklistAlertListController _controller;

  LaudoChecklistAlertListPresenter(this._view, this._alerts) {
    _controller = LaudoChecklistAlertListController();
    _init();
  }

  _init() async {}

  @override
  LaudoChecklistAlertListController get controller => _controller;
  @override
  List<LaudoOption> get alerts => _alerts;

  @override
  onSearchBarQUeryChanged(String query) {}

  @override
  onSelectedItemListener(int index) {
    _view.popWithResult(_alerts[index]);
  }

  @override
  Color colorFor(int index) {
    switch (_alerts[index].type) {
      case LaudoOptionTypes.OK:
        return Colors.green;
      case LaudoOptionTypes.Alert:
        return Colors.yellow;
      case LaudoOptionTypes.Risk:
        return Colors.red;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  IconData iconFor(int index) {
    switch (_alerts[index].type) {
      case LaudoOptionTypes.OK:
        return Icons.check;
      case LaudoOptionTypes.Alert:
        return MdiIcons.exclamation;
      case LaudoOptionTypes.Risk:
        return MdiIcons.close;
      default:
        return null;
    }
  }
}
