import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/bottom_button.dart';
import 'package:laudo_eletronico/common/widgets/listview_header.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/widgets/laudo_checklist_list_item.dart';

class LaudoChecklistListBuilder extends StatelessWidget {
  final LaudoChecklistPresenterContract _presenter;

  LaudoChecklistListBuilder(this._presenter);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            ListviewHeader(
              showHeader: index == 0,
              globalizationKey: "laudo_descritivo_list_header",
            ),
            Material(
              color: Color.fromARGB(255, 240, 240, 240),
              child: LaudoChecklistListItem(_presenter, index),
            ),
            index == _presenter.items.length - 1
                ? BottomButton(
                    stringsKey: !_presenter.isLastStep ? "btn_next_step" : "btn_last_step",
                    onClick: _presenter.onBtnNextSteapClickListener,
                    isEnabled: true,
                  )
                : Container(),
          ],
        );
      },
      itemCount: _presenter.items.length,
    );
  }
}
