import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_contract.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/widget/photo_viewer_camera.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewerTabviewItem extends StatelessWidget {
  final PhotoViewerPresenterContract _presenter;
  final BuildContext _context;
  final Function _flashlight;

  PhotoViewerTabviewItem(this._presenter, this._context, this._flashlight);

  @override
  Widget build(BuildContext context) {
    final tabs = _presenter.photos
        .map<Widget>(
          (photo) => Stack(
                children: <Widget>[
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  Center(
                    child: PhotoView(
                      minScale: 0.3,
                      maxScale: 4.0,
                      imageProvider: FileImage(
                        File.fromUri(
                          Uri(
                            path: photo.path,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(4, 4, 20, 4),
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(_context).pop();
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            photo.description ?? "",
                            style: Theme.of(_context).primaryTextTheme.title,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt),
                            iconSize: 40,
                            color: Colors.white,
                            onPressed: _presenter.onBttnGoCameraClickListener,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment(0, 1),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(Icons.delete),
                        iconSize: 40,
                        color: Colors.white,
                        onPressed: () {
                          _presenter.delete(photo);
                        },
                      ),
                    ),
                  ),
                ],

              ),
        )
        .toList();
    tabs.insert(0, PhotoViewerCamera(_presenter, _context, _flashlight));

    return TabBarView(
      controller: _presenter.controller.tabController,
      children: tabs,
    );
  }
}
