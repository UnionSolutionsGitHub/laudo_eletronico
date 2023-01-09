import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/listview_header.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/widgets/laudo_checklist_alert_list_item.dart';

class LaudoDescritivoAlertListBuilder extends StatelessWidget {
  final LaudoChecklistAlertListPresenterContract _presenter;

  LaudoDescritivoAlertListBuilder(this._presenter);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return  Column(
          children: <Widget>[
            ListviewHeader(
              showHeader: index == 0,
              globalizationKey: "laudo_descritivo_alert_list_list_header",
            ),
            LaudoChecklistAlertListItem(_presenter, index),
          ],
        );
      },
      itemCount: _presenter.alerts.length,
    );
  }
}