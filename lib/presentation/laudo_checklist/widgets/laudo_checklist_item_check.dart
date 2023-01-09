import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_contract.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LaudoChecklistItemCheck extends StatelessWidget {
  final int _index;
  final LaudoChecklistPresenterContract _presenter;

  LaudoChecklistItemCheck(this._presenter, this._index);

  @override
  Widget build(BuildContext context) {
    return Container(
		child: Row(
			children: <Widget>[
				Expanded(
					child: Container(),
				),
				_circledIcon(
					context,
					_presenter.showOkButton ? Icons.check : null,
					_presenter.checkAnswered(
						_presenter.items[_index], LaudoOptionTypes.OK)
						? Colors.green
						: Colors.blueGrey[300],
					LaudoOptionTypes.OK,
				),
				_circledIcon(
					context,
					_presenter.showAlertButton ? MdiIcons.exclamation : null,
					_presenter.checkAnswered(
						_presenter.items[_index], LaudoOptionTypes.Alert)
						? Colors.yellow
						: Colors.blueGrey[300],
					LaudoOptionTypes.Alert,
				),
				_circledIcon(
					context,
					_presenter.showRiskButton ? MdiIcons.close : null,
					_presenter.checkAnswered(
						_presenter.items[_index], LaudoOptionTypes.Risk)
						? Colors.red
						: Colors.blueGrey[300],
					LaudoOptionTypes.Risk,
				),
				_circledIcon(
					context,
					_presenter.items[_index].isNotApplicable
						? MdiIcons.cancel
						: null,
					_presenter.checkAnswered(
						_presenter.items[_index],
						LaudoOptionTypes.NA,
					)
						? Colors.blueAccent
						: Colors.blueGrey[300],
					LaudoOptionTypes.NA,
				),
				Expanded(
					child: Container(),
				),
			],
		),
	);
  }

  Widget _circledIcon(
    BuildContext context,
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
          _presenter.onAnswerClickListener(_presenter.items[_index], answer);
        },
      ),
    );
  }
}
