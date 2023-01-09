import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/item_execution/item_execution_bloc.dart';
import 'package:laudo_eletronico/model/check_item.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LaudoChecklistItemCheck extends StatelessWidget {
  final CheckItem _checkItem;
  final ItemExecutionBloc _bloc;

  LaudoChecklistItemCheck(this._checkItem, this._bloc);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text(
            _checkItem.type,
            textAlign: TextAlign.left,
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                _circledIcon(
                  _checkItem.showOkButton ? Icons.check : null,
                  _checkItem.checkedItem == LaudoOptionTypes.OK
                      ? Colors.green
                      : Colors.blueGrey[300],
                  LaudoOptionTypes.OK,
                ),
                _circledIcon(
                  _checkItem.showAlertButton ? MdiIcons.exclamation : null,
                  _checkItem.checkedItem == LaudoOptionTypes.Alert
                      ? Colors.yellow
                      : Colors.blueGrey[300],
                  LaudoOptionTypes.Alert,
                ),
                _circledIcon(
                  _checkItem.showRiskButton ? MdiIcons.close : null,
                  _checkItem.checkedItem == LaudoOptionTypes.Risk
                      ? Colors.red
                      : Colors.blueGrey[300],
                  LaudoOptionTypes.Risk,
                ),
                _circledIcon(
                  _checkItem.showNAButton ? MdiIcons.cancel : null,
                  _checkItem.checkedItem == LaudoOptionTypes.NA
                      ? Colors.blueAccent
                      : Colors.blueGrey[300],
                  LaudoOptionTypes.NA,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circledIcon(
    IconData icon,
    Color color,
    String answer,
  ) {
    if (icon == null) {
      return Container();
    }

    return Container(
      height: 45,
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: () {
          _bloc.onCheckItem(_checkItem.type, answer, _checkItem.inputType);
        },
      ),
    );
  }
}
