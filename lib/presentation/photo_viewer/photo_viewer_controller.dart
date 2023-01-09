import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PhotoViewerController {
  TextEditingController _txfdPhotoDescriptionController;
  CameraController cameraController;
  TabController tabController;

  PhotoViewerController() {
    _txfdPhotoDescriptionController = TextEditingController();
  }

  TextEditingController get txfdPhotoDescriptionController => _txfdPhotoDescriptionController;

  dispose() {
    _txfdPhotoDescriptionController.dispose();
    this.cameraController.dispose();
    this.tabController.dispose();
  }
}
