import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/presentation/laudo_camera/laudo_camera_contract.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';

import './laudo_camera_tabview_top_item.dart';
import './laudo_camera_tabview_water_mark.dart';
import './laudo_camera_tabview_progress.dart';

class LaudoCameraTabView extends StatelessWidget {
  final _screenSize;
  final LaudoCameraPresenterContract _presenter;
  final Function changeCamera;

  LaudoCameraTabView(this._screenSize, this._presenter, this.changeCamera);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: TabBarView(
            controller: _presenter.tabController,
            children: _presenter.items
                .map((item) => Stack(
                      children: <Widget>[
                        !_presenter.isAnswered(item)
                            ? Column(
                                children: [
                                  LaudoCameraTabViewTopItem(
                                    _screenSize,
                                    item.descption,
                                  ),
                                  _presenter.isShowingWatermark ? LaudoCameraTabViewWaterMark(item.key) : Expanded(child: Container()),
                                  LaudoCameraTabViewProgress(
                                    _screenSize,
                                    _presenter.items.indexOf(item) + 1,
                                    _presenter.items.length,
                                  ),
                                  Container(
                                    alignment: Alignment.bottomCenter,
                                    margin: EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            height: 80,
                                            child: RawMaterialButton(
                                              shape: CircleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              onPressed: () {
                                                _presenter.onBtnTakePictureClickListener(item);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Material(
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: Text(
                                        item.descption,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: <Widget>[
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          Center(
                                            child: PhotoView(
                                              minScale: 0.3,
                                              maxScale: 4.0,
                                              backgroundDecoration: BoxDecoration(color: Colors.white),
                                              imageProvider: FileImage(
                                                File.fromUri(
                                                  Uri(
                                                    path: _presenter.photoPath(item),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _presenter.showDelete
                                        ? Container(
                                            height: 60,
                                            child: RawMaterialButton(
                                              child: Icon(Icons.delete, size: 40),
                                              shape: CircleBorder(
                                                side: BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              elevation: 1.0,
                                              onPressed: () {
                                                _showConfirmDeletePhotoDialog(context, item);
                                              },
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                        item.isMandatory
                            ? Container(
                                margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
                                alignment: Alignment(1, -1),
                                child: Icon(
                                  MdiIcons.alertCircleOutline,
                                  color: Colors.red,
                                ),
                              )
                            : Container(),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          height: 80,
                          width: 60,
                          alignment: Alignment(-1, -1),
                          child: RawMaterialButton(
                            shape: CircleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.transparent,
                              ),
                            ),
                            onPressed: this.changeCamera,
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
        )
      ],
    );
  }

  _showConfirmDeletePhotoDialog(BuildContext context, ItemConfiguration item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            GlobalizationStrings.of(context).value("alert_title_warning"),
          ),
          content: Text(
            GlobalizationStrings.of(context).value("laudo_camera_alert_delete_photo"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                GlobalizationStrings.of(context).value("alert_button_negative"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                GlobalizationStrings.of(context).value("alert_button_positive"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _presenter.deletePhoto(item);
              },
            ),
          ],
        );
      },
    );
  }
}
