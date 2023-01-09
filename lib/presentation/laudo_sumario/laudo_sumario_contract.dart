import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';

abstract class LaudoSumarioViewContract {
  notifyDataChanged();
  navigateTo(Widget view);
  showAlertConfirmDeleteAdditionalPhoto(AdditionalPhoto photo);
}

abstract class LaudoSumarioPresenterContract {
  bool get isLoading;
  int get photosLenght;
  int get paintingsLenght;
  int get structuresLenght;
  int get identifyLenght;
  int get photosDoneLenght;
  int get paintingsDoneLenght;
  int get structuresDoneLenght;
  int get identifyDoneLenght;
  bool get canDoUpload;
  bool get additionalPhoto;
  bool get showPainting;
  bool get showStructure;
  bool get showIdentify;
  List<String> get photos;
  List<String> get photosAdicionais;

  reloadData();
  onSelectedItemListener(String itemType);
  onTapPhotoListener(int index, bool isFotoAdicional);
  deleteAdditionalPhoto(AdditionalPhoto photo);
  uploadLaudo();
}
