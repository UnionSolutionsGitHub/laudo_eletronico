import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laudo_eletronico/common/widgets/circled_icon.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/vistorias_pendentes_contract.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/widgets/vistorias_pendentes_text_column.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class VistoriasPendentesListagemItem extends StatelessWidget {
  final VistoriasPendentesPresenterContract presenter;
  final int index;

  VistoriasPendentesListagemItem({
    @required this.presenter,
    @required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          width: 50.0,
          child: Image.asset(
            "./assets/images/marcas/${this.presenter.laudos[this.index].vehicleLogoName ?? "ni"}.png",
          ),
        ),
        Expanded(
          child: VistoriasPendentesTextColumn(
            carPlate: this.presenter.laudos[this.index].carPlate,
            searchText: this.presenter.queryController.text,
            carName: this.presenter.laudos[this.index].vehicleModel,
            startReportDateTime: this.presenter.laudos[this.index].date,
          ),
        ),
        Container(
          height: 70,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              this.presenter.laudos[index].foreignId != null && this.presenter.laudos[index].foreignId > 0
                  ? InkWell(
                      onTap: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Informações"),
                                content: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(this.presenter.laudos[index].agendamento.address),
                                      Text(
                                          "${DateFormat(GlobalizationStrings.of(context).value("date_format")).format(this.presenter.laudos[index].agendamento.date)} ${GlobalizationStrings.of(context).value(this.presenter.laudos[index].agendamento.periodo)}"),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Ok"),
                                    onPressed: () => Navigator.of(context).pop(),
                                  )
                                ],
                              );
                            },
                          ),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        child: Icon(
                          MdiIcons.clockOutline,
                          color: Colors.green,
                        ),
                      ),
                    )
                  : Container(),
              !this.presenter.isNewFlowEnabled ?
              Row(
                children: <Widget>[
                  this.presenter?.laudos[this.index]?.hasPhoto == true
                      ? CircledIcon(
                          Icons.photo_camera,
                          this.presenter?.laudos[this.index]?.isPhotoDone == true ? AppColors.primary : AppColors.disabled,
                        )
                      : Container(),
                  this.presenter?.laudos[this.index]?.hasPainting == true
                      ? CircledIcon(
                          MdiIcons.formatColorFill,
                          this.presenter?.laudos[this.index]?.isPaintingDone == true ? AppColors.primary : AppColors.disabled,
                        )
                      : Container(),
                  this.presenter?.laudos[this.index]?.hasStructure == true
                      ? CircledIcon(
                          MdiIcons.carHatchback,
                          this.presenter?.laudos[this.index]?.isStructureDone == true ? AppColors.primary : AppColors.disabled,
                        )
                      : Container(),
                  this.presenter?.laudos[this.index]?.hasIdentify == true
                      ? CircledIcon(
                          MdiIcons.fileDocument,
                          this.presenter?.laudos[this.index]?.isIdentifyDone == true ? AppColors.primary : AppColors.disabled,
                        )
                      : Container(),
                ],
              ): Text(this.presenter.newFlowStatus(this.presenter.laudos[this.index])),
            ],
          ),
        ),
      ],
    );
  }
}
