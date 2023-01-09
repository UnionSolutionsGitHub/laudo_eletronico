import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';

abstract class LaudoCameraViewContract {
  navigatorPush(MaterialPageRoute route);
  showAlertLaudoFinished();
  notifyDataChanged();
  showAlertWannaFinish();
  showAlertCantGoNextStep();
  Future loadCamera();
}

abstract class LaudoCameraPresenterContract {
  TabController get tabController;
  CameraController cameraController;
  List<ItemConfiguration> get items;
  bool get isLoading;
  bool get showDelete;
  bool isAnswered(ItemConfiguration item);
  String photoPath(ItemConfiguration item);
  onBtnTakePictureClickListener(ItemConfiguration item);
  deletePhoto(ItemConfiguration item);
  Function get onBtnNextStepClickListener;
  goNextStep();
  bool get isShowingWatermark;
  onBttnWatermarkClickListener();
  onBttnAddPhotoClickListener();
  bool get additionalPhotos;
  bool isCameraTimedOut;
  bool get showMenu;
  cameraStartTimeout();
  cameraCancelTimeout();
  cameraRenewTimeout();
  dispose();
  bool get cameraDisposed;
  int zoon;
  addFromGallery();
  resumeFromBackground();
  onAppEnterBackground();
}