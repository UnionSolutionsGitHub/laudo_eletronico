import 'package:flutter/material.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_contract.dart';

class LaudoChecklistAlertListItem extends StatelessWidget {
  final LaudoChecklistAlertListPresenterContract _presenter;
  final int _index;

  LaudoChecklistAlertListItem(this._presenter, this._index);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          color: Colors.white,
          child: ListTile(
            onTap: () {
              _presenter.onSelectedItemListener(_index);
            },
            leading: _circledIcon(
              context,
              _presenter.iconFor(_index),
              _presenter.colorFor(_index),
            ),
            title: RichText(
              text: TextSpan(
                text: _presenter.alerts[_index].value.substring(
                  0,
                  _presenter
                      .controller.txfdSearchBarQueryController.text.length,
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: _presenter.alerts[_index].value.substring(_presenter
                        .controller.txfdSearchBarQueryController.text.length),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 2.0,
        ),
      ],
    );
  }

  Widget _circledIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      height: 45,
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
