import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/listview_header.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/main.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';

import './laudo_sumario_contract.dart';
import './laudo_sumario_presenter.dart';
import './widgets/laudo_sumario_button.dart';

class LaudoSumarioView extends StatefulWidget {
  final Laudo _laudo;

  LaudoSumarioView(this._laudo);
  @override
  _LaudoSumarioViewState createState() => _LaudoSumarioViewState();
}

class _LaudoSumarioViewState extends State<LaudoSumarioView>
    with RouteAware
    implements LaudoSumarioViewContract {
  LaudoSumarioPresenterContract _presenter;

  @override
  void initState() {
    _presenter = LaudoSumarioPresenter(this, this.widget._laudo);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _presenter.reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          GlobalizationStrings.of(context).value("laudo_fotos_appbar_title"),
        ),
        actions: <Widget>[
          _presenter.canDoUpload
              ? IconButton(
                  icon: Icon(Icons.cloud_upload),
                  onPressed: _presenter.uploadLaudo,
                )
              : Container(),
        ],
      ),
      body: _presenter.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              shrinkWrap: true,
              children: <Widget>[
                Center(
                  child: ListviewHeader(
                    showHeader: true,
                    globalizationKey: "laudo_sumario_header_description",
                  ),
                ),
                LaudoSumarioButton(
                  "${GlobalizationStrings.of(context).value("laudo_sumario_btn_photo_text")} ${_presenter.photosDoneLenght}/${_presenter.photosLenght}",
                  () => _presenter
                      .onSelectedItemListener(ItemConfigurationType.FOTO),
                ),
                _presenter.showPainting ? LaudoSumarioButton(
                  "${GlobalizationStrings.of(context).value("laudo_sumario_btn_painting_text")} ${_presenter.paintingsDoneLenght}/${_presenter.paintingsLenght}",
                  () => _presenter
                      .onSelectedItemListener(ItemConfigurationType.PINTURA),
                ) : Container(),
                _presenter.showStructure ? LaudoSumarioButton(
                  "${GlobalizationStrings.of(context).value("laudo_sumario_btn_structure_text")} ${_presenter.structuresDoneLenght}/${_presenter.structuresLenght}",
                  () => _presenter
                      .onSelectedItemListener(ItemConfigurationType.ESTRUTURA),
                ) : Container(),
				_presenter.showIdentify ? LaudoSumarioButton(
					"${GlobalizationStrings.of(context).value("laudo_sumario_btn_identify_text")} ${_presenter.identifyDoneLenght}/${_presenter.identifyLenght}",
						() => _presenter
						.onSelectedItemListener(ItemConfigurationType.IDENTIFICACAO),
				) : Container(),
                
                /* LaudoSumarioGaleriaFotos(
                  _presenter.photos,
                  onTapPhotoListener: _presenter.onTapPhotoListener,
                ), */
                Container(
                  margin: EdgeInsets.only(top: 5),
                ),
                _presenter.additionalPhoto
                    ? LaudoSumarioButton(
                        GlobalizationStrings.of(context)
                            .value("laudo_sumario_btn_fotos_adicionais"),
                        () => _presenter.onSelectedItemListener(
                              ItemConfigurationType.FOTO_ADICIONAL,
                            ),
                        icon: Icons.add,
                      )
                    : Container(),
                /* LaudoSumarioGaleriaFotos(
                  _presenter.photosAdicionais,
                  onTapPhotoListener: _presenter.onTapPhotoListener,
                  isFotoAdicional: true,
                ), */
              ],
            ),
    );
  }

  @override
  notifyDataChanged() {
    this.setState(() {});
  }

  @override
  navigateTo(Widget view) {
    Navigator.push(
      this.context,
      MaterialPageRoute(
        builder: (BuildContext context) => view,
      ),
    );
  }

  @override
  showAlertConfirmDeleteAdditionalPhoto(AdditionalPhoto photo) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(this.context).value("alert_title_warning"),
          ),
          content: Text(
            GlobalizationStrings.of(this.context)
                .value("laudo_sumario_alert_delete_additional_photo_text"),
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context)
                    .value("alert_button_negative"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                GlobalizationStrings.of(this.context)
                    .value("alert_button_positive"),
              ),
              onPressed: () {
                _presenter.deleteAdditionalPhoto(photo);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
