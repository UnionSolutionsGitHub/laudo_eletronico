import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_presenter.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/widgets/laudo_checklist_alert_list_builder.dart';

class LaudoChecklistAlertListView extends StatefulWidget {
  final List<LaudoOption> _list;

  LaudoChecklistAlertListView(this._list);

  @override
  _LaudoChecklistAlertListViewState createState() {
    return new _LaudoChecklistAlertListViewState();
  }
}

class _LaudoChecklistAlertListViewState extends State<LaudoChecklistAlertListView> implements LaudoChecklistAlertListViewContract {
  LaudoChecklistAlertListPresenterContract _presenter;

  @override
  void initState() {
    _presenter = LaudoChecklistAlertListPresenter(this, this.widget._list);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          GlobalizationStrings.of(context).value("laudo_descritivo_alert_list_appbar_title"),
        ),
      ),
      body: LaudoDescritivoAlertListBuilder(_presenter),
    );
    /*return SearchBar(
      title: GlobalizationStrings.of(context).value("laudo_descritivo_alert_list_appbar_title"),
      queryController: _presenter.controller.txfdSearchBarQueryController,
      onQueryChanged: _presenter.onSearchBarQUeryChanged,
      onQuerySubmitted: (s) {},
      child: LaudoDescritivoAlertListBuilder(_presenter),
    );*/
  }

  @override
  notifyDataChanged() {
    this.setState(() {});
  }

  @override
  popWithResult(LaudoOption alert) {
    Navigator.of(this.context).pop(alert);
  }
}
