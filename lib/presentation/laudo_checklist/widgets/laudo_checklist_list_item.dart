import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/input_type.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/widgets/laudo_checklist_item_check.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/widgets/laudo_checklist_item_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LaudoChecklistListItem extends StatelessWidget {
  final int _index;
  final LaudoChecklistPresenterContract presenter;

  LaudoChecklistListItem(this.presenter, this._index);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
            alignment: Alignment(-1, -1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    presenter.items[_index].descption,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                presenter.items[_index].isMandatory
                    ? Icon(
                        MdiIcons.alertCircleOutline,
                        color: Colors.red,
                      )
                    : Container(),
              ],
            ),
          ),
          _inputWidget(),
        ],
      ),
    );
  }

  StatelessWidget _inputWidget() {
    switch (presenter.items[_index].inputType) {
      case InputType.check:
        return LaudoChecklistItemCheck(presenter, _index);
      default:
        return LaudoChecklistItemText(presenter, _index);
    }
  }
}
