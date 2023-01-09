import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:laudo_eletronico/bloc/grid_view/grid_view_bloc.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/additional_photo_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class AdditionalPhotosBloc extends GridViewBloc {
  final Laudo laudo;
  final FileManager fileManager;

  final _additionalPhotos = BehaviorSubject<List<AdditionalPhoto>>();

  //
  // Outputs
  //
  Stream<List<AdditionalPhoto>> get additionalPhotos =>
      _additionalPhotos.stream;

  Stream<double> get screenWidth => screenWidthController.stream;

  AdditionalPhotosBloc({
    @required this.laudo,
    @required this.fileManager,
  }) {
    _additionalPhotos.sink.add(laudo.additionalPhotos);
  }

  File photoFor(int index) {
    final photoPath = _additionalPhotos.value[index].path;
    final photoFile = File(photoPath);
    return photoFile;
  }

  File thumbnailFor(int index) {
    final photoPath = _additionalPhotos.value[index].path;
    final thumbnailPath = fileManager.getThumbnailPath(photoPath);
    final thumbnailFile = File(thumbnailPath);
    return thumbnailFile;
  }

  String descriptionFor(int index) {
    return _additionalPhotos.value[index].description;
  }

  Future takeNewAdditionalPhoto(ImageSource source,
      {String description}) async {
    File image = await ImagePicker.pickImage(source: source);
    if (image == null) return;

    FileManager fileManager = await FileManager.instance;
    File compressedImage =
        await fileManager.compressImageAndThumbnail(image.path);

    final additionalPhoto = AdditionalPhoto(
      path: compressedImage.path,
      description: description,
      laudo: laudo,
    );

    await _saveAdditionalPhoto(additionalPhoto);
    _sendAdditionalPhoto(additionalPhoto);

    final list = _additionalPhotos.value;
    list.add(additionalPhoto);
    _additionalPhotos.add(list);
  }

  _saveAdditionalPhoto(AdditionalPhoto photo) async {
    final dao = AdditionalPhotoDAO();
    photo.id = await dao.insert(photo);
  }

  _sendAdditionalPhoto(AdditionalPhoto photo) {
    UnionSolutionsService().uploadImage(photo.path).then((result) {
      print(result);
    });
  }

  onPhotoDeleted(String fileName) async {
    var photos = _additionalPhotos.value;

    for (var photo in photos) {
      if (photo.path.split('/').last == fileName) {
        final additionalPhotoDao = AdditionalPhotoDAO();

        additionalPhotoDao.delete({
          additionalPhotoDao.columnId: photo.id,
        });

        laudo.additionalPhotos.remove(photo);
        photos.remove(photo);
        break;
      }
    }
    _additionalPhotos.sink.add(photos);
  }

  double get addPhotoButtonSize => 0.5 * cardWidth;

  double get addPhotoButtonPadding => cardWidth * 0.2;

  double get addPhotoIconSize => addPhotoButtonSize * 0.6;

  @override
  void dispose() {
    _additionalPhotos.close();
    super.dispose();
  }
}
