import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AlbumPhoto {
  String description, _imagePath, _emptyCardImagePath;
  bool isMandatory = false;

  AlbumPhoto({
    String imagePath,
    String emptyCardImagePath,
    this.description,
    this.isMandatory,
  }) {
    _imagePath = imagePath;
    _emptyCardImagePath = emptyCardImagePath;
  }

  Image get photo => _imagePath == null ? null : Image?.file(File(_imagePath));
  set imagePath(String path) => _imagePath = path;

  Image get emptyCard => _emptyCardImagePath == null ? null : Image?.asset(_emptyCardImagePath, color: Colors.black);
  set emptyCardImagePath(String path) => _emptyCardImagePath = path;
}