import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/item_execution/item_execution_bloc.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/album_photo.dart';
import 'package:laudo_eletronico/model/check_item.dart';
import 'package:laudo_eletronico/model/input_type.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_view.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/vistorias_pendentes_view.dart';

import 'widgets/item_execution_check.dart';
import 'widgets/item_execution_text.dart';

class ItemExecutionView extends StatelessWidget {
  final ItemExecutionBloc _bloc;
  final bool _popToRoot;

  ItemExecutionView(this._bloc, this._popToRoot);

  Widget _buildProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _bloc.showPhoto = (view) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext ctx) => view,
          ),
        );

    _bloc.showListOptions = (options) async => await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                LaudoChecklistAlertListView(options),
          ),
        );

    final onBackPressed = () {
      if (!_popToRoot) {
        Navigator.of(context).pop();
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => VistoriasPendentesView(
            configMenu: ConfigurationMenuButton(),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    };

    return StreamBuilder<bool>(
        stream: _bloc.isReadyToEdit,
        builder: (context, snapshot) {
          final isReadyToEdit = snapshot.data ?? false;

          return WillPopScope(
            onWillPop: isReadyToEdit ? onBackPressed : () async => false,
            child: Scaffold(
              body: !isReadyToEdit
                  ? _buildProgressIndicator()
                  : _buildBody(screenSize, context),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _bloc.goNext().catchError((_) => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          GlobalizationStrings.of(context)
                              .value("alert_title_warning"),
                        ),
                        content: Text(
                          "Item obrigatório. Favor preencher todas as informações", //GlobalizationStrings.of(context).value("laudo_camera_alert_cant_go_next_step"),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              GlobalizationStrings.of(context)
                                  .value("alert_button_ok"),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    )),
                label: Text("Próximo"),
                icon: Icon(Icons.arrow_forward),
              ),
            ),
          );
        });
  }

  Widget _buildBody(Size screenSize, BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          buildHeader(context),
          Expanded(
            child: ListView(
              children: <Widget>[
                buildContent(screenSize),
                buildReliefSpace(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildReliefSpace() {
    return Container(
      height: 60,
    );
  }

  Widget buildContent(Size screenSize) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          buildItemNameArea(),
          buildPhotoArea(screenSize),
          buildPaintingArea(),
          buildStructureArea(),
          buildIdentificationArea(),
        ],
      ),
    );
  }

  Container buildHeader(BuildContext context) {
    return Container(
      color: AppColors.offwhiteBackground,
      height: 60.0,
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: RaisedButton(
              elevation: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.arrow_back,
                    color: Colors.blue,
                  ),
                  Text(
                    "Sumário",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          Expanded(
            child: Align(
              child: StreamBuilder(
                stream: _bloc.itemsCounter,
                builder: (ctx, snapshot) => Text(
                  snapshot.hasData ? snapshot.data : "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              alignment: Alignment.center,
            ),
            flex: 1,
          ),
          Expanded(
            flex: 1,
            child: StreamBuilder<bool>(
                stream: _bloc.isMandatory,
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData || !snapshot.data) {
                    return Container();
                  }

                  return Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.star,
                      color: Colors.red,
                      size: 15,
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget buildItemNameArea() {
    return Column(
      children: <Widget>[
        StreamBuilder(
          stream: _bloc.itemName,
          builder: (ctx, snapshot) => Text(
            snapshot.data ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  StreamBuilder<AlbumPhoto> buildPhotoArea(Size screenSize) {
    return StreamBuilder<AlbumPhoto>(
      stream: _bloc.photoStream,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        if (snapshot.data.photo != null) {
          return Card(
            child: Container(
              margin: EdgeInsets.all(10),
              child: GestureDetector(
                child: snapshot.data.photo,
                onTap: _bloc.onPhotoClickedListener,
              ),
              height: screenSize.width * 0.6,
            ),
          );
        }

        return Card(
          child: Column(children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: GestureDetector(
                child: snapshot.data.emptyCard,
                onTap: _bloc.takePicture,
              ),
              height: screenSize.width * 0.6,
            ),
            Container(
              height: 1,
              color: Color.fromARGB(255, 240, 240, 240),
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: _bloc.takePicture,
                child: SizedBox(
                  height: 50,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Tirar foto"),
                        Icon(Icons.add_a_photo)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: Color.fromARGB(255, 240, 240, 240),
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _bloc.getPhotoFromGallery,
                child: SizedBox(
                  height: 50,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Buscar da galeria"),
                        Icon(Icons.add_photo_alternate)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  StreamBuilder<List<CheckItem>> buildIdentificationArea() {
    return StreamBuilder<List<CheckItem>>(
      stream: _bloc.identificationStream,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        final list = snapshot.data;

        return buildIdentificationList(list);
      },
    );
  }

  ListView buildIdentificationList(List<CheckItem> list) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        switch (list[index].inputType) {
          case InputType.check:
            return LaudoChecklistItemCheck(list[index], _bloc);
          default:
            return LaudoChecklistItemText(list[index], _bloc);
        }
      },
      itemCount: list.length,
    );
  }

  StreamBuilder<CheckItem> buildStructureArea() {
    return StreamBuilder<CheckItem>(
      stream: _bloc.structureStream,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return LaudoChecklistItemCheck(snapshot.data, _bloc);
      },
    );
  }

  StreamBuilder<CheckItem> buildPaintingArea() {
    return StreamBuilder<CheckItem>(
      stream: _bloc.paintingStream,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return LaudoChecklistItemCheck(snapshot.data, _bloc);
      },
    );
  }
}
