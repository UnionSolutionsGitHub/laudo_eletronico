import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import '../vistorias_pendentes_contract.dart';
import './vistorias_pendentes_listagem_item.dart';
import 'package:laudo_eletronico/common/widgets/listview_header.dart';

class VistoriasPendentesListagemBuilder extends StatelessWidget {
  final VistoriasPendentesPresenterContract presenter;

  VistoriasPendentesListagemBuilder(this.presenter);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            ListviewHeader(
              showHeader: index == 0,
              globalizationKey: "vistoria_pendentes_list_header",
            ),
            Material(
              color: presenter.isItemSelected(index)
                  ? AppColors.lightBlue
                  : Colors.white,
              child: InkWell(
                onTap: () => presenter.onItemClicked(index),
                onLongPress: () => presenter.onChangeItemSelection(index),
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: VistoriasPendentesListagemItem(
                    presenter: presenter,
                    index: index,
                  ),
                ),
              ),
            ),
            Divider(
              color: AppColors.darkGray,
              height: 1.0,
            ),
            index == presenter.laudos.length - 1
                ? Container(
                    height: 90,
                  )
                : Container(),
          ],
        );
      },
      itemCount: presenter.laudos.length,
    );
  }
}
