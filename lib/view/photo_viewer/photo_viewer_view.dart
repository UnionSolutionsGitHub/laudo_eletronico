import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/photo_viwer/photo_viwer_bloc.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewerView extends StatelessWidget {
  final PhotoViwerBloc _bloc;

  PhotoViewerView(this._bloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StreamBuilder<File>(
            stream: _bloc.fileStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return Center(
                child: PhotoView(
                  minScale: 0.3,
                  maxScale: 4.0,
                  imageProvider: FileImage(snapshot.data),
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StreamBuilder<String>(
                stream: _bloc.fileDescriptionStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return Container(
                    margin: EdgeInsets.only(top: 40),
                    width: double.infinity,
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: Text(
                      snapshot.data,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                },
              ),
              Container(
                alignment: Alignment.bottomCenter,
                height: 60,
                child: RawMaterialButton(
                  child: Icon(
                    Icons.delete,
                    size: 40,
                    color: Colors.white,
                  ),
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  elevation: 1.0,
                  onPressed: () {
                    _showDialog(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(
              GlobalizationStrings.of(context).value('alert_title_warning'),
            ),
            content: Text(
              GlobalizationStrings.of(context)
                  .value('delete_picture_photo_viewer_message'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  GlobalizationStrings.of(context)
                      .value('alert_button_negative'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  GlobalizationStrings.of(context)
                      .value('alert_button_positive'),
                ),
                onPressed: () {
                  _bloc
                      .deletePhoto()
                      .then(
                        (_) => Navigator.of(context).pop(),
                      )
                      .catchError(
                        (e) => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                    content: Text(e),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          "Ok",
                                        ),
                                      )
                                    ],
                                  ),
                            ),
                      );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }
}
