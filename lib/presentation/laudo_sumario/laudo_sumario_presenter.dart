import 'package:laudo_eletronico/bloc/additional_photos/additional_photos_bloc.dart';
import 'package:laudo_eletronico/bloc/photo_gallery/photo_gallery_bloc.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/additional_photo_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/presentation/laudo_camera/laudo_camera_view.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_view.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_view.dart';
import 'package:laudo_eletronico/view/photo_gallery/photo_gallery_view.dart';
import 'package:laudo_eletronico/view/additional_photos/additional_photos_view.dart';

import './laudo_sumario_contract.dart';

class LaudoSumarioPresenter implements LaudoSumarioPresenterContract {
  LaudoSumarioViewContract _view;
  Laudo _laudo;
  bool _isLoading = true, _canDoUpload = false;

  LaudoSumarioPresenter(this._view, this._laudo) {
    _canDoUpload = _laudo.isPaintingDone &&
        _laudo.isPhotoDone &&
        _laudo.isStructureDone &&
        _laudo.isIdentifyDone;
    _init();
  }

  _init() async {
    _isLoading = false;
    _view.notifyDataChanged();
  }

  @override
  bool get isLoading => _isLoading;

  @override
  int get photosDoneLenght =>
      _laudo?.answers
          ?.where((answer) => answer.item.type == ItemConfigurationType.FOTO)
          ?.length ??
      0;

  @override
  int get paintingsDoneLenght =>
      _laudo?.answers
          ?.where((answer) => answer.item.type == ItemConfigurationType.PINTURA)
          ?.length ??
      0;

  @override
  int get structuresDoneLenght =>
      _laudo?.answers
          ?.where(
              (answer) => answer.item.type == ItemConfigurationType.ESTRUTURA)
          ?.length ??
      0;

  @override
  int get identifyDoneLenght =>
      _laudo?.answers
          ?.where((answer) =>
              answer.item.type == ItemConfigurationType.IDENTIFICACAO)
          ?.length ??
      0;

  @override
  int get photosLenght =>
      _laudo?.configuration?.items
          ?.where((item) => item.type == ItemConfigurationType.FOTO)
          ?.length ??
      0;

  @override
  int get paintingsLenght =>
      _laudo?.configuration?.items
          ?.where((item) => item.type == ItemConfigurationType.PINTURA)
          ?.length ??
      0;

  @override
  int get structuresLenght =>
      _laudo?.configuration?.items
          ?.where((item) => item.type == ItemConfigurationType.ESTRUTURA)
          ?.length ??
      0;

  @override
  int get identifyLenght =>
      _laudo?.configuration?.items
          ?.where((item) => item.type == ItemConfigurationType.IDENTIFICACAO)
          ?.length ??
      0;

  @override
  bool get canDoUpload => _canDoUpload;

  @override
  bool get showPainting => _laudo.configuration.items
      .any((item) => item.type == ItemConfigurationType.PINTURA);

  @override
  bool get showStructure => _laudo.configuration.items
      .any((item) => item.type == ItemConfigurationType.ESTRUTURA);

  @override
  bool get showIdentify => _laudo.configuration.items
      .any((item) => item.type == ItemConfigurationType.IDENTIFICACAO);

  @override
  List<String> get photos =>
      _laudo?.answers
          ?.where((answer) => answer.item.type == ItemConfigurationType.FOTO)
          ?.map((answer) {
        final path = answer?.attachment?.path ?? answer.value;
        return "${path.replaceAll(".png", "")}_thumbnail.png";
      })?.toList() ??
      List<String>();

  @override
  List<String> get photosAdicionais => _laudo.additionalPhotos
      .map((photo) => "${photo.path.replaceAll(".png", "")}_thumbnail.png")
      .toList();

  @override
  bool get additionalPhoto => _laudo.configuration.additionalPhoto;

  @override
  onSelectedItemListener(String itemType) async {
    switch (itemType) {
      case ItemConfigurationType.FOTO:
        //_view.navigateTo(LaudoCameraView(_laudo, false));
        final fileManager = await FileManager.instance;
        
        _view.navigateTo(
          PhotoGalleryView(
            PhotoGalleryBloc(
              laudo: _laudo,
              fileManager: fileManager,
            ),
            false,
          ),
        );
        return;
      case ItemConfigurationType.PINTURA:
        _view.navigateTo(
          LaudoChecklistView(_laudo, ItemConfigurationType.PINTURA),
        );
        return;
      case ItemConfigurationType.ESTRUTURA:
        _view.navigateTo(
          LaudoChecklistView(_laudo, ItemConfigurationType.ESTRUTURA),
        );
        return;
      case ItemConfigurationType.IDENTIFICACAO:
        _view.navigateTo(
          LaudoChecklistView(_laudo, ItemConfigurationType.IDENTIFICACAO),
        );
        return;
      case ItemConfigurationType.FOTO_ADICIONAL:
        final fileManager = await FileManager.instance;
        _view.navigateTo(
          AdditionalPhotosView(bloc: AdditionalPhotosBloc(laudo: _laudo, fileManager: fileManager)),
        );
        return;
    }
  }

  @override
  reloadData() {
    _canDoUpload =
        _laudo.isPaintingDone && _laudo.isPhotoDone && _laudo.isStructureDone;
    _isLoading = true;
    _view.notifyDataChanged();
    _init();
  }

  @override
  onTapPhotoListener(int index, bool isFotoAdicional) async {
    if (isFotoAdicional) {
      final fileManager = await FileManager.instance;
      _view.navigateTo(
        AdditionalPhotosView(
          bloc: AdditionalPhotosBloc(laudo: _laudo, fileManager: fileManager),
        ),
      );
      return;
    }

    final answer = _laudo?.answers
        ?.where((answer) => answer.item.type == ItemConfigurationType.FOTO)
        ?.toList()[index];

    _view.navigateTo(LaudoCameraView(
      _laudo,
      false,
      photo: answer.item,
    ));
  }

  @override
  deleteAdditionalPhoto(AdditionalPhoto photo) async {
    final additionalPhotoDao = AdditionalPhotoDAO();

    await additionalPhotoDao.delete({
      additionalPhotoDao.columnId: photo.id,
    });

    _laudo.additionalPhotos.remove(photo);

    _view.notifyDataChanged();
  }

  @override
  uploadLaudo() {
    _view.navigateTo(LaudoConcluidoView(_laudo));
  }
}
