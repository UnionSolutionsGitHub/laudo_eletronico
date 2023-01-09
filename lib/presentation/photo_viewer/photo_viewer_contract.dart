import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_controller.dart';

abstract class PhotoViewerViewContract {
  notifyDataChanged();
}

abstract class PhotoViewerPresenterContract {
  int zoon;

  PhotoViewerController get controller;
  int get photosLength;
  List<AdditionalPhoto> get photos;

  onBtnTakePictureClickListener();
  onBttnGoCameraClickListener();
  delete(AdditionalPhoto photo);
  addFromGallery();
}
