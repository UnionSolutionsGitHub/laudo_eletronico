import 'dart:io';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laudo_eletronico/common/compress_imagem.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/answer_attachment.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_view.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_view.dart';
import 'package:laudo_eletronico/presentation/photo_viewer/photo_viewer_view.dart';
import 'package:path_provider/path_provider.dart';

import './laudo_camera_contract.dart';

class LaudoCameraPresenter implements LaudoCameraPresenterContract {
  LaudoCameraViewContract _view;
  Laudo _laudo;
  TabController _tabController;
  bool _isLoading = true,
      _canGoNextStep,
      _showDelete = true,
      _isShowingWatermark = true,
      _showMenu = true,
      _cameraDisposed = false,
      _isAddingPhotoFromGallery = false;
  ItemConfiguration photo;
  Directory _applicationDirectory;

  LaudoCameraPresenter(this._view, this._laudo, {this.photo}) {
    _canGoNextStep = _laudo.isPhotoDone;
    getApplicationDocumentsDirectory().then((directory) => _applicationDirectory = directory);
    _init();
  }

  _init() async {
    this.zoon = 0;
    _tabController = TabController(
      length: this.items.length,
      vsync: _view as SingleTickerProviderStateMixin,
    );

    if (this.photo == null) {
      _tabController.addListener(_tabIndexListener);
    }

    _checkCanGoNextStep();

    _checkPhotoIndex();

    _isLoading = false;
    _view.notifyDataChanged();
  }

  Function get _tabIndexListener => () async {
        final item = this.items[_tabController.index];

        _showMenu = !this.isAnswered(item);

        if (_showMenu) {
          if (_cameraDisposed) {
            await _view.loadCamera();
            _cameraDisposed = false;
          } else {
            this.cameraRenewTimeout();
          }
        } else {
          this.cameraCancelTimeout();
          this.cameraController?.dispose();
          _cameraDisposed = true;
        }

        _view.notifyDataChanged();
      };

  @override
  TabController get tabController => _tabController;
  @override
  CameraController cameraController;

  @override
  List<ItemConfiguration> get items => _laudo.configuration.items
      .where(
        (item) => item.type == ItemConfigurationType.FOTO,
      )
      .toList();

  @override
  bool get isLoading => _isLoading;

  @override
  Function get onBtnNextStepClickListener => goNextStep;

  @override
  bool get showDelete => _showDelete;

  @override
  bool get isShowingWatermark => _isShowingWatermark;

  @override
  bool isAnswered(ItemConfiguration item) {
    return _laudo?.answers?.any(
          (answer) => answer?.item?.id == item?.id,
        ) ==
        true;
  }

  @override
  Future onBtnTakePictureClickListener(ItemConfiguration item) async {
    this.cameraRenewTimeout();

    if (_checkStepFinished()) {
      return;
    }

    _showDelete = false;

    final path = "${_applicationDirectory.path}/${DateTime.now().toIso8601String()}";
    final filePath = "$path.png";
    final thumbnailPath = "${path}_thumbnail.png";

    await cameraController.takePicture(filePath);

    await _saveImage(filePath, thumbnailPath);
    await _saveAnswer(item, filePath);
    _goNextPhoto(item);
    _checkCanGoNextStep();

    this.zoon = 0;
    this.isCameraTimedOut = true;
    _view.loadCamera();

    _view.notifyDataChanged();
  }

  @override
  addFromGallery() async {
    _isAddingPhotoFromGallery = true;
    this.onAppEnterBackground();

    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image?.path?.contains('/') != true) {
      _isAddingPhotoFromGallery = false;
      return;
    }

    if (_checkStepFinished()) {
      _isAddingPhotoFromGallery = false;
      return;
    }

    _showDelete = false;

    final path = "${_applicationDirectory.path}/${DateTime.now().toIso8601String()}";
    final filePath = "$path.png";
    final thumbnailPath = "${path}_thumbnail.png";

    File(filePath).writeAsBytesSync(image.readAsBytesSync());
    final item = this.items[_tabController.index];

    await _saveImage(filePath, thumbnailPath);
    await _saveAnswer(item, filePath);
    _goNextPhoto(item);
    _checkCanGoNextStep();

    this.zoon = 0;
    _view.notifyDataChanged();

    _isAddingPhotoFromGallery = false;
    _cameraDisposed = true;
  }

  @override
  resumeFromBackground() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_isAddingPhotoFromGallery) {
      await _view.loadCamera();
      _cameraDisposed = false;
      //_view.notifyDataChanged();
    }
  }

  @override
  onAppEnterBackground() {
    this.cameraController?.dispose();
    _cameraDisposed = true;
  }

  @override
  deletePhoto(ItemConfiguration item) async {
    //this.cameraRenewTimeout();

    final answer = _laudo.answers.firstWhere((answer) => answer.item.id == item.id);

    final file = File.fromUri(
      Uri(path: answer.value),
    );

    file.delete();
    _laudo.answers.remove(answer);

    final answerDao = AnswerDAO();

    answerDao.delete({
      answerDao.columnId: answer.id,
    });

    _checkCanGoNextStep();

    await _view.loadCamera();
    _cameraDisposed = false;
    _showMenu = true;

    _view.notifyDataChanged();
  }

  @override
  goNextStep() {
    if (_canGoNextStep != true) {
      _view.showAlertCantGoNextStep();
      return;
    }

    final nextStep = _laudo.configuration.items.any((item) => item.type == ItemConfigurationType.PINTURA)
        ? ItemConfigurationType.PINTURA
        : _laudo.configuration.items.any((item) => item.type == ItemConfigurationType.ESTRUTURA) ? ItemConfigurationType.ESTRUTURA : null;

    this.cameraController.dispose();
    _cameraDisposed = true;

    if (nextStep == null) {
      _view.navigatorPush(
        MaterialPageRoute(
          builder: (BuildContext context) => LaudoConcluidoView(_laudo),
        ),
      );
      return;
    }

    _view.navigatorPush(
      MaterialPageRoute(
        builder: (BuildContext context) => LaudoChecklistView(_laudo, nextStep),
      ),
    );
  }

  Future _saveImage(String filePath, String thumbnailPath) async {
    final photoProperties = await FlutterNativeImage.getImageProperties(filePath);
    final photowidth = photoProperties.width > photoProperties.height ? 1024 : 768;
    final image = await CompressImage.compress(filePath, width: photowidth);

    File(filePath).writeAsBytesSync(image.readAsBytesSync());

    final thumbnail = await CompressImage.compress(filePath);
    File(thumbnailPath).writeAsBytesSync(thumbnail.readAsBytesSync());
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

        answer.attachment.id = await answerAttachmentDao.insert(answer.attachment);
        answerDao.update(answer);
      },
    );
  }

  _checkPhotoIndex() {
    if (this.photo != null) {
      _showPhoto();
      return;
    }

    _goNextPhoto(
      _laudo.configuration.items.firstWhere(
        (item) => item.type == ItemConfigurationType.FOTO,
      ),
      withDelay: false,
    );
  }

  _showPhoto() async {
    final index = _laudo.configuration.items.where((i) => i.type == ItemConfigurationType.FOTO).toList().indexOf(this.photo);

    this.photo = null;
    _tabController.animateTo(index);

    final item = this.items[index];
    _showMenu = !this.isAnswered(item);

    Future(() async {
      await Future.delayed(const Duration(milliseconds: 1000));
      _tabController.addListener(_tabIndexListener);
    });
  }

  _goNextPhoto(ItemConfiguration item, {bool withDelay = true}) {
    int nextIndex = 0;
    final index = _laudo.configuration.items.where((i) => i.type == ItemConfigurationType.FOTO).toList().indexOf(item);

    final photoItems = _laudo.configuration.items.where((item) => item.type == ItemConfigurationType.FOTO).toList();
    for (int i = index; i < photoItems.length; i++) {
      final item = photoItems[i];
      if (!_laudo.answers.any((answer) => answer.item.id == item.id)) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex == 0) {
      for (int i = 0; i < photoItems.length; i++) {
        final item = photoItems[i];
        if (!_laudo.answers.any((answer) => answer.item.id == item.id)) {
          nextIndex = i;
          break;
        }
      }
    }

    if (withDelay) {
      _animateNextPicWithDelay(nextIndex);
    } else {
      _tabController.animateTo(nextIndex);
    }
  }

  _animateNextPicWithDelay(int nextIndex) async {
    await Future.delayed(const Duration(seconds: 1));
    _tabController.animateTo(nextIndex);

    _showDelete = true;
    _view.notifyDataChanged();
  }

  _checkCanGoNextStep() {
    final mandatoryItems = _laudo.configuration.items.where((item) => item.type == ItemConfigurationType.FOTO && item.isMandatory);

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

  bool _checkStepFinished() {
    if (_laudo.answers.length == _laudo.configuration.items.length) {
      _view.showAlertLaudoFinished();
      return true;
    }

    return false;
  }

  @override
  onBttnAddPhotoClickListener() async {
    this.onAppEnterBackground();
    //_isCalledAdditionalPhoto = true;
    // if (cameraController.description.lensDirection == CameraLensDirection.front) {
    //   await _view.loadCamera();
    // }

    _view.navigatorPush(
      MaterialPageRoute(
        builder: (BuildContext context) => PhotoViewerView(
              _laudo,
            ),
      ),
    );
  }

  @override
  onBttnWatermarkClickListener() {
    _isShowingWatermark = !_isShowingWatermark;
    _view.notifyDataChanged();
  }

  @override
  String photoPath(ItemConfiguration item) {
    final answer = _laudo.answers.firstWhere((answer) => answer.item.id == item.id);
    return answer?.attachment?.path ?? answer.value;
  }

  @override
  bool get additionalPhotos => _laudo.configuration.additionalPhoto;

  @override
  bool isCameraTimedOut;

  @override
  bool get showMenu => _showMenu;

  CancelableOperation _cameraTimeoutTask;

  cameraStartTimeout() {
    if (_cameraDisposed) {
      return;
    }

    _cameraTimeoutTask?.cancel();

    final lensDirection = this.cameraController?.description?.lensDirection;

    _cameraTimeoutTask = CancelableOperation.fromFuture(
      Future.delayed(const Duration(seconds: 40)),
    );

    _cameraTimeoutTask.value.whenComplete(() {
      if (cameraController.description.lensDirection != lensDirection) {
        return;
      }

      cameraController.dispose();

      isCameraTimedOut = true;

      _view.notifyDataChanged();
    });
  }

  cameraCancelTimeout() async {
    await _cameraTimeoutTask?.cancel();
  }

  cameraRenewTimeout() async {
    await _cameraTimeoutTask?.cancel();
    cameraStartTimeout();
  }

  @override
  dispose() {
    _tabController.dispose();
    this.cameraController.dispose();
  }

  @override
  bool get cameraDisposed => _cameraDisposed;

  @override
  int zoon;
}
