import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/additional_photos/additional_photos_bloc.dart';
import 'package:laudo_eletronico/bloc/photo_gallery/photo_gallery_bloc.dart';
import 'package:laudo_eletronico/common/widgets/album_card.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/album_photo.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/vistorias_pendentes_view.dart';
import 'package:laudo_eletronico/view/additional_photos/additional_photos_view.dart';

class PhotoGalleryView extends StatelessWidget {
  final PhotoGalleryBloc _bloc;
  final bool _popToRoot;

  PhotoGalleryView(this._bloc, this._popToRoot);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final carWidth = (screenSize.width / 3) - (halfSpace * 2);
    final cardHeight = carWidth * 1.11;

    _bloc.showPhoto = (view) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext ctx) => view,
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
                configMenu:
                    ConfigurationMenuButton(),
              ),
        ),
        (Route<dynamic> route) => false,
      );
    };

    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Fotos"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext ctx) => AdditionalPhotosView(
                          bloc: AdditionalPhotosBloc(
                              laudo: _bloc.laudo,
                              fileManager: _bloc.fileManager),
                        ),
                  ),
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Galeria de fotos",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StreamBuilder<String>(
                          stream: _bloc.picsTakedStream,
                          builder: (context, snapshot) {
                            String data = snapshot.data;

                            if (!snapshot.hasData) {
                              data = "0/0";
                            }

                            return Text(
                              data,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                StreamBuilder<List<MapEntry<ItemConfiguration, AlbumPhoto>>>(
                  stream: _bloc.photosStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      primary: false,
                      childAspectRatio: carWidth / (cardHeight + 60),
                      children: List.generate(
                        snapshot.data.length,
                        (index) {
                          return AlbumCard(
                            width: carWidth,
                            height: cardHeight,
                            child: snapshot.data[index].value.photo,
                            isMandatory: snapshot.data[index].key.isMandatory,
                            emptyBackground:
                                snapshot.data[index].value.emptyCard,
                            onTap: () => _bloc.onGridItemClickedListener(
                                snapshot.data[index].key),
                            onCornerButtonPressed: () =>
                                _bloc.onCornerGridItemClickedListener(
                                    snapshot.data[index].key),
                            text: snapshot.data[index].value.description,
                          );
                        },
                      ),
                    );
                  },
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: RaisedButton(
                      color: AppColors.primary,
                      textColor: Colors.white,
                      disabledColor: AppColors.disabled,
                      child: Text(
                        GlobalizationStrings.of(context).value("btn_next_step"),
                      ),
                      onPressed: () {
                        _bloc
                            .goNextStep()
                            .then(
                              (widget) => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext ctx) => widget,
                                    ),
                                  ),
                            )
                            .catchError(
                              (_) => showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: Text(
                                            GlobalizationStrings.of(context)
                                                .value("alert_title_warning"),
                                          ),
                                          content: Text(
                                            GlobalizationStrings.of(context).value(
                                                "laudo_camera_alert_cant_go_next_step"),
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
                                  ),
                            );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
