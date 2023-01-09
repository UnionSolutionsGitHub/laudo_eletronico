import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laudo_eletronico/bloc/photo_viwer/photo_viwer_bloc.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/album_photo.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/answer_attachment.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_view.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_view.dart';
import 'package:laudo_eletronico/view/photo_viewer/photo_viewer_view.dart';
import 'package:rxdart/rxdart.dart';

class PhotoGalleryBloc extends BlocBase {
  Laudo _laudo;
  FileManager _fileManager;

  bool _canGoNextStep = false;
  bool _isTakingPicture = false;

  final _photos =
      BehaviorSubject.seeded(List<MapEntry<ItemConfiguration, AlbumPhoto>>());
  final _picsTaked = BehaviorSubject<String>();

  Function(PhotoViewerView) _showPhoto;

  PhotoGalleryBloc({
    @required Laudo laudo,
    @required FileManager fileManager,
  }) : assert(laudo != null) {
    _laudo = laudo;
    _fileManager = fileManager;

    _photosListener = _photos.listen(_photoListener);

    _photos.add(_photosList);
  }

  List get _photosList => _laudo.configuration.items
          .where(
        (configurationItem) =>
            configurationItem.type == ItemConfigurationType.FOTO,
      )
          .map(
        (configurationItem) {
          final albumPhoto = AlbumPhoto(
            description: configurationItem.descption,
            emptyCardImagePath:
                "./assets/images/water_marks/${configurationItem.key}.png",
          );

          if (_laudo.answers
              .any((answer) => answer.item.id == configurationItem.id)) {
            final answer = _laudo.answers.firstWhere(
              (answer) => answer.item.id == configurationItem.id,
            );

            albumPhoto.imagePath = _fileManager
                .getThumbnailPath(answer?.attachment?.path ?? answer.value);
          }

          return MapEntry(configurationItem, albumPhoto);
        },
      ).toList();

  Stream<List<MapEntry<ItemConfiguration, AlbumPhoto>>> get photosStream =>
      _photos.stream;

  Stream<String> get picsTakedStream => _picsTaked.stream;

  set showPhoto(Function(PhotoViewerView) delegate) => _showPhoto = delegate;

  Laudo get laudo => _laudo;
  FileManager get fileManager => _fileManager;

  StreamSubscription _photosListener;

  _photoListener(list) {
    final picsTaked = _laudo.answers
        .where((answer) => answer.item.type == ItemConfigurationType.FOTO)
        .length;
    _picsTaked.add("$picsTaked/${list.length}");

    _checkCanGoNextStep();
  }

  onGridItemClickedListener(ItemConfiguration configurationItem) {
    if (_isTakingPicture) {
      return;
    }

    if (_laudo.answers
        .any((answer) => answer.item.id == configurationItem.id)) {
      final answer = _laudo.answers
          .firstWhere((answer) => answer.item.id == configurationItem.id);

      final photoViewerBloc = PhotoViwerBloc(
        fileDescription: configurationItem.descption,
        filePath: answer?.attachment?.path ?? answer.value,
        onDeleted: _onPhotoDeleted,
      );

      _showPhoto(PhotoViewerView(photoViewerBloc));

      return;
    }

    _takePicture(configurationItem);
  }

  onCornerGridItemClickedListener(ItemConfiguration configurationItem) {
    if (_isTakingPicture) {
      return;
    }

    _isTakingPicture = true;

    ImagePicker.pickImage(source: ImageSource.gallery).then((file) async {
      final compressedFile =
          await _fileManager.compressImageAndThumbnail(file.path);
      await _saveAnswer(configurationItem, compressedFile.path);
      _photos.add(_photosList);
      _isTakingPicture = false;
    }).catchError((_) => _isTakingPicture = false);
  }

  Future<StatefulWidget> goNextStep() async {
    if (_canGoNextStep != true) {
      throw Exception();
    }

    final nextStep = _determineNextStep();

    if (nextStep == null) {
      return LaudoConcluidoView(_laudo);
    }

    return LaudoChecklistView(_laudo, nextStep);
  }

  String _determineNextStep() {
    String nextStep;
    for (var item in _laudo.configuration.items) {
      if (item.type == ItemConfigurationType.FOTO) continue;
      nextStep = ItemConfigurationType.nextStepBetween(nextStep, item.type);
      if (nextStep == ItemConfigurationType.PINTURA) break;
    }
    return nextStep;
  }

  _takePicture(ItemConfiguration configurationItem) {
    _isTakingPicture = true;

    ImagePicker.pickImage(source: ImageSource.camera).then((file) async {
      final compressedFile =
          await _fileManager.compressImageAndThumbnail(file.path);
      await _saveAnswer(configurationItem, compressedFile.path);
      _photos.add(_photosList);
      _isTakingPicture = false;
    }).catchError((_) => _isTakingPicture = false);
  }

  Future _saveAnswer(ItemConfiguration item, String filePath) async {
    final answerDao = AnswerDAO();
    final answerAttachmentDao = AnswerAttachmentDAO();

    final answer = Answer(
      item: item,
      laudo: _laudo,
      value: filePath,
    );

    answer.id = await answerDao.insert(answer);

    _laudo.answers.add(answer);

    UnionSolutionsService().uploadImage(filePath).then(
      (url) async {
        answer.attachment = AnswerAttachment(
          answer: answer,
          path: filePath,
          url: url,
        );

        answer.value = url;

        answer.attachment.id =
            await answerAttachmentDao.insert(answer.attachment);
        answerDao.update(answer);
      },
    );
  }

  _onPhotoDeleted(String fileName) {
    Answer deletedAnswer;

    for (var answer in _laudo.answers) {
      if (answer?.attachment?.path?.split('/')?.last == fileName ||
          answer?.value?.split('/')?.last == fileName) {
        deletedAnswer = answer;
        break;
      }
    }

    _laudo.answers.remove(deletedAnswer);
    final answerDao = AnswerDAO();

    answerDao.delete({
      answerDao.columnId: deletedAnswer.id,
    });

    _photos.add(_photosList);
  }

  _checkCanGoNextStep() {
    final mandatoryItems = _laudo.configuration.items.where(
        (item) => item.type == ItemConfigurationType.FOTO && item.isMandatory);

    for (var item in mandatoryItems) {
      if (!_laudo.answers.any((answer) => answer.item.id == item.id)) {
        _canGoNextStep = false;
        _updateLaudo();
        return;
      }
    }

    _canGoNextStep = true;
    _updateLaudo();
  }

  _updateLaudo() async {
    if (_laudo.isPhotoDone != _canGoNextStep) {
      final laudoDao = LaudoDAO();

      _laudo.isPhotoDone = _canGoNextStep;
      await laudoDao.update(_laudo);
    }
  }

  @override
  void dispose() {
    _photos.close();
    _picsTaked.close();

    _photosListener.cancel();
    super.dispose();
  }
}
