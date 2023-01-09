import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laudo_eletronico/bloc/photo_viwer/photo_viwer_bloc.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/summary_item_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/album_photo.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/answer_attachment.dart';
import 'package:laudo_eletronico/model/check_item.dart';
import 'package:laudo_eletronico/model/input_type.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/model/summary_item.dart';
import 'package:laudo_eletronico/view/photo_viewer/photo_viewer_view.dart';
import 'package:rxdart/rxdart.dart';

class ItemExecutionBloc extends BlocBase {
  Laudo _laudo;
  FileManager _fileManager;
  UnionSolutionsService _service;
  AnswerDAO _answerDAO;
  AnswerAttachmentDAO _answerAttachmentDAO;
  LaudoDAO _laudoDAO;
  List<LaudoOption> _laudoOptions;
  List<SummaryItem> _summaryItems;

  bool _isTakingPicture = false;

  final _order = BehaviorSubject<int>();
  final _isMandatory = BehaviorSubject<bool>();
  final _itemName = BehaviorSubject<String>();
  final _itemsCounter = BehaviorSubject<String>();
  final _photo = BehaviorSubject<AlbumPhoto>();
  final _painting = BehaviorSubject<CheckItem>();
  final _structure = BehaviorSubject<CheckItem>();
  final _identification = BehaviorSubject<List<CheckItem>>();
  final _isReadyToEdit = BehaviorSubject<bool>.seeded(false);

  StreamSubscription _orderListener;

  Function(PhotoViewerView) _showPhoto;
  Future<LaudoOption> Function(List<LaudoOption>) _showListOptions;

  ItemExecutionBloc({
    @required Laudo laudo,
    @required FileManager fileManager,
    @required UnionSolutionsService service,
    @required AnswerDAO answerDAO,
    @required AnswerAttachmentDAO answerAttachmentDAO,
    @required LaudoDAO laudoDAO,
    @required List<LaudoOption> laudoOptions,
    @required List<SummaryItem> summaryItems,
    int order = 1,
  }) : assert(order > 0) {
    _laudo = laudo;
    _fileManager = fileManager;
    _service = service;
    _answerDAO = answerDAO;
    _answerAttachmentDAO = answerAttachmentDAO;
    _laudoDAO = laudoDAO;
    _laudoOptions = laudoOptions;
    _summaryItems = summaryItems;

    _orderListener = _order.listen(_onOrderChangedListener);

    order = laudo.configuration.items.any((item) => item.order == order)
        ? order
        : laudo.configuration.items.first.order;

    _order.add(order);
  }

  Stream<AlbumPhoto> get photoStream => _photo.stream;
  Stream<bool> get isMandatory => _isMandatory.stream;
  Stream<String> get itemName => _itemName.stream;
  Stream<String> get itemsCounter => _itemsCounter.stream;
  Stream<CheckItem> get paintingStream => _painting.stream;
  Stream<CheckItem> get structureStream => _structure.stream;
  Stream<List<CheckItem>> get identificationStream => _identification.stream;
  Stream<bool> get isReadyToEdit => _isReadyToEdit.stream;

  List<ItemConfiguration> get _currentItems => _laudo?.configuration?.items
      ?.where((configurationItem) => configurationItem.order == _order.value)
      ?.toList();

  set showPhoto(Function(PhotoViewerView) delegate) => _showPhoto = delegate;
  set showListOptions(
          Future<LaudoOption> Function(List<LaudoOption>) delegate) =>
      _showListOptions = delegate;

  takePicture() {
    if (_isTakingPicture) {
      return;
    }

    _isTakingPicture = true;
    _isReadyToEdit.add(false);

    final configurationItem = _itemConfiguration(ItemConfigurationType.FOTO);
    try {
      ImagePicker.pickImage(source: ImageSource.camera).then((file) async {
        final compressedFile =
            await _fileManager.compressImageAndThumbnail(file.path);
        final answer =
            await _saveAnswer(configurationItem, compressedFile.path);
        _photo.add(_createAlbumPhoto());
        _isTakingPicture = false;
        _isReadyToEdit.add(true);
        _uploadImage(answer, compressedFile.path);
      }).catchError((_) {
        _isTakingPicture = false;
        _isReadyToEdit.add(true);
      });
    } catch (e) {
      print("CRASH AO TIRAR FOTO: $e");
    }
  }

  onPhotoClickedListener() {
    final configurationItem = _itemConfiguration(ItemConfigurationType.FOTO);

    if (_showPhoto == null) {
      return;
    }

    final answer = _laudo.answers.firstWhere(
      (answer) => answer.item.id == configurationItem.id,
    );

    final photoViewerBloc = PhotoViwerBloc(
      fileDescription: configurationItem.descption,
      filePath: answer?.attachment?.path ?? answer.value,
      onDeleted: _onPhotoDeleted,
    );

    _showPhoto(PhotoViewerView(photoViewerBloc));
  }

  getPhotoFromGallery() {
    if (_isTakingPicture) {
      return;
    }

    _isTakingPicture = true;

    final configurationItem = _itemConfiguration(ItemConfigurationType.FOTO);

    ImagePicker.pickImage(source: ImageSource.gallery).then((file) async {
      final compressedFile =
          await _fileManager.compressImageAndThumbnail(file.path);
      final answer = await _saveAnswer(configurationItem, compressedFile.path);
      _photo.add(_createAlbumPhoto());
      _isTakingPicture = false;
      _uploadImage(answer, compressedFile.path);
    }).catchError((_) => _isTakingPicture = false);
  }

  onCheckItem(String type, String answerType, InputType inputType) async {
    final configurationItem = _itemConfiguration(type, inputType: inputType);
    final value = await _getCheckValue(configurationItem, answerType);

    if (value?.isNotEmpty != true) {
      return;
    }

    await _saveAnswer(configurationItem, value);

    switch (type) {
      case ItemConfigurationType.PINTURA:
        final checkitem = _createCheckItem(type);
        _painting.add(checkitem);
        break;
      case ItemConfigurationType.ESTRUTURA:
        final checkitem = _createCheckItem(type);
        _structure.add(checkitem);
        break;
      case ItemConfigurationType.IDENTIFICACAO:
        final checkitems = _createCheckItemsList(type);
        _identification.add(checkitems);
        break;
    }
  }

  onAnswerText(String type, String value, InputType inputType) async {
    final configurationItem = _itemConfiguration(type, inputType: inputType);
    await _saveAnswer(configurationItem, value);

    switch (type) {
      case ItemConfigurationType.PINTURA:
        final checkitem = _createCheckItem(type);
        _painting.add(checkitem);
        break;
      case ItemConfigurationType.ESTRUTURA:
        final checkitem = _createCheckItem(type);
        _structure.add(checkitem);
        break;
      case ItemConfigurationType.IDENTIFICACAO:
        final checkitems = _createCheckItemsList(type);
        _identification.add(checkitems);
        break;
    }
  }

  Future goNext() async {
    if (_isReadyToEdit.value != true) {
      return;
    }

    for (var item in _currentItems) {
      //verificação de obrigatoriedade do item e avaliação de nulidade do campo, atualização do card caso retorne ao sumário com o campo não preenchido.
      if (item.isMandatory) {
        final isAllAnswered = _answer(item).value?.isNotEmpty == true;        
        if (!isAllAnswered) {
          throw Exception;
        } else {
          final summaryItem = _currentSummaryItem;
          await _changeStatusOf(summaryItem);
          final dao = SummaryItemDAO();
          dao.update(summaryItem);
        }
      }
    }
    //antiga forma de realição de verificação de obrigatoriedades.
    // final isAllAnswered = !_haveMandatory ||
    //     _currentItems.any((item) =>
    //         item.isMandatory && _answer(item).value?.isNotEmpty == true);

    // if (!isAllAnswered) {
    //   throw Exception;
    // }

    final nextOrder = _laudo.configuration.items
        .firstWhere((item) =>
            item.order > _order.value || _isLastItem && item.order > 0)
        .order;

    _order.add(nextOrder);
  }

  Future<String> _getCheckValue(
      ItemConfiguration item, String answerType) async {
    final options = _laudoOptions
        .where((option) =>
            option.laudoType == item.type &&
            option.type == answerType &&
            option.subtype == item.subtype)
        .toList();

    if (options.length <= 0) {
      return answerType;
    }

    if (options.length == 1) {
      return options.first.value;
    }

    final selectedOption = await _showListOptions(options);

    return selectedOption?.value;
  }

  Future<Answer> _saveAnswer(ItemConfiguration item, String value) async {
    final answer = _answer(item, orElse: () {
      final r = Answer(
        item: item,
        laudo: _laudo,
      );

      _laudo.answers.add(r);

      return r;
    });

    answer.value = value;

    //verificação de nulidade do valor do item quando o mesmo esta sendo alterado.
    if ((answer?.id ?? 0) > 0 && _answer(item).value?.isNotEmpty == true) {
      await _answerDAO.update(answer);
      return answer;
    }

    answer.id = await _answerDAO.insert(answer);

    // Update the current summaryItem's status
    final summaryItem = _currentSummaryItem;
    await _changeStatusOf(summaryItem);
    final dao = SummaryItemDAO();
    dao.update(summaryItem);

    _checkOldFlowGroup();

    return answer;
  }

  SummaryItem get _currentSummaryItem =>
      _summaryItems.firstWhere((item) => item.order == _order.value);

  /// Changes the status of a [summaryItem] based on the available [_laudo.answers].
  _changeStatusOf(SummaryItem summaryItem) async {
    final dao = SummaryItemDAO();
    int itemsAnsweredCount = 0;
    for (var itemConfiguration in summaryItem.itemConfigurations) {
      if (_thereIsAnAnswerFor(itemConfiguration)) {
        //verificação para atualização do status do item quando a informação presente no campo é deletada.
        if (itemConfiguration.isMandatory &&
            _answer(itemConfiguration).value?.isNotEmpty != true) {
          summaryItem.status = SummaryItemStatus.incomplete;
          dao.update(summaryItem);
          _isReadyToEdit.add(true);
          return;
        }
        itemsAnsweredCount++;
      } else if (itemConfiguration.isMandatory) {
        summaryItem.status = SummaryItemStatus.incomplete;
        dao.update(summaryItem);
        _isReadyToEdit.add(true);
        return;
      }
    }

    if (itemsAnsweredCount == summaryItem.itemConfigurations.length) {
      summaryItem.status = SummaryItemStatus.complete;
    } else {
      summaryItem.status = SummaryItemStatus.acceptable;
    }

    await dao.update(summaryItem);
    _isReadyToEdit.add(true);
  }

  /// Returns [true] if there is an [Answer] object, in [_laudo.answers], corresponding
  /// to this [itemConfiguration], or returns [false] otherwise.
  bool _thereIsAnAnswerFor(ItemConfiguration itemConfiguration) {
    return _laudo.answers.firstWhere(
            (Answer answer) => answer.item.id == itemConfiguration.id,
            orElse: () => null) !=
        null;
  }

  _uploadImage(Answer answer, String filePath) {
    _service.uploadImage(filePath).then(
      (url) async {
        answer.attachment = AnswerAttachment(
          answer: answer,
          path: filePath,
          url: url,
        );

        answer.value = url;

        answer.attachment.id =
            await _answerAttachmentDAO.insert(answer.attachment);
        _answerDAO.update(answer);
      },
    );
  }

  _onPhotoDeleted(String fileName) async {
    Answer deletedAnswer;

    for (var answer in _laudo.answers) {
      if (answer?.attachment?.path?.split('/')?.last == fileName ||
          answer?.value?.split('/')?.last == fileName) {
        deletedAnswer = answer;
        break;
      }
    }

    _laudo.answers.remove(deletedAnswer);

    await _answerDAO.delete({
      _answerDAO.columnId: deletedAnswer.id,
    });
    await _changeStatusOf(_currentSummaryItem);
    _photo.add(_createAlbumPhoto());
  }

  _onOrderChangedListener(int order) {
    _itemName.add(_itemDescription);
    _isMandatory.add(_haveMandatory);
    _itemsCounter.add("$_currentItemIndex/$_totalItems");
    _photo.add(_createAlbumPhoto());
    _painting.add(_createCheckItem(ItemConfigurationType.PINTURA));
    _structure.add(_createCheckItem(ItemConfigurationType.ESTRUTURA));
    _identification
        .add(_createCheckItemsList(ItemConfigurationType.IDENTIFICACAO));
    _changeStatusOf(_currentSummaryItem);
  }

  String get _itemDescription => _currentItems
      ?.firstWhere((item) => item.descption != null && item.descption != "")
      ?.descption;
  bool get _haveMandatory =>
      _currentItems?.any(
        (item) => item.isMandatory,
      ) ==
      true;
  int get _currentItemIndex =>
      groupBy(_laudo.configuration.items,
              (ItemConfiguration item) => item.order)
          .keys
          .toList()
          .indexOf(_order.value) +
      1;

  int get _totalItems => groupBy(
          _laudo.configuration.items, (ItemConfiguration item) => item.order)
      .keys
      .length;

  bool get _isLastItem =>
      groupBy(_laudo.configuration.items,
                  (ItemConfiguration item) => item.order)
              .keys
              .toList()
              .indexOf(_order.value) +
          1 ==
      _totalItems;

  AlbumPhoto _createAlbumPhoto() {
    final configurationItem = _itemConfiguration(ItemConfigurationType.FOTO);

    if (configurationItem == null) {
      return null;
    }

    final answer = _answer(configurationItem);

    return AlbumPhoto(
      description: configurationItem?.descption,
      emptyCardImagePath:
          "./assets/images/water_marks/${configurationItem?.key}.png",
      imagePath: answer?.attachment?.path ?? answer?.value,
      isMandatory: configurationItem?.isMandatory,
    );
  }

  CheckItem _createCheckItem(String itemType, {InputType inputType}) {
    final configurationItem =
        _itemConfiguration(itemType, inputType: inputType);

    if (configurationItem == null) {
      return null;
    }

    final answer = _answer(configurationItem);

    return CheckItem(
      description: configurationItem.descption,
      type: itemType,
      inputType: configurationItem.inputType,
      checkedItem: _laudoOptions
              ?.firstWhere(
                  (option) =>
                      option.laudoType == itemType &&
                      option.value == answer?.value,
                  orElse: () => null)
              ?.type ??
          answer?.value,
      showOkButton: _showButton(itemType, LaudoOptionTypes.OK),
      showAlertButton: _showButton(itemType, LaudoOptionTypes.Alert),
      showRiskButton: _showButton(itemType, LaudoOptionTypes.Risk),
      showNAButton: configurationItem.isNotApplicable,
    );
  }

  List<CheckItem> _createCheckItemsList(String itemType) {
    final itemConfigurations =
        _currentItems?.where((item) => item.type == itemType);

    if (itemConfigurations == null) return null;

    final checkItems = List<CheckItem>();
    itemConfigurations.forEach(
      (i) => checkItems.add(_createCheckItem(i.type, inputType: i.inputType)),
    );
    return checkItems;
  }

  ItemConfiguration _itemConfiguration(String type, {InputType inputType}) =>
      _currentItems?.firstWhere(
        (item) =>
            item.type == type &&
            (inputType == null || item.inputType == inputType),
        orElse: () => null,
      );

  Answer _answer(ItemConfiguration configurationItem, {Function orElse}) =>
      _laudo?.answers?.firstWhere(
        (item) =>
            item.item.id == configurationItem.id &&
            item.item.type == configurationItem.type &&
            (item.item.inputType == null ||
                item.item.inputType == configurationItem.inputType),
        orElse: () => orElse != null ? orElse() : null,
      );

  bool _showButton(String itemType, String buttonType) => _laudoOptions.any(
        (option) => option.laudoType == itemType && option.type == buttonType,
      );

  _checkOldFlowGroup() {
    _laudo.isPhotoDone = _checkGroupDone(ItemConfigurationType.FOTO);
    _laudo.isPaintingDone = _checkGroupDone(ItemConfigurationType.PINTURA);
    _laudo.isStructureDone = _checkGroupDone(ItemConfigurationType.ESTRUTURA);
    _laudo.isIdentifyDone =
        _checkGroupDone(ItemConfigurationType.IDENTIFICACAO);

    _laudoDAO.update(_laudo);
  }

  bool _checkGroupDone(String group) {
    final mandatoryItems = _laudo.configuration.items
        .where((item) => item.type == group && item.isMandatory);

    for (var item in mandatoryItems) {
      if (!_laudo.answers.any((answer) => answer.item.id == item.id)) {
        return false;
      }
    }

    return true;
  }

  @override
  void dispose() {
    _photo.close();
    _painting.close();
    _structure.close();
    _identification.close();
    _isMandatory.close();
    _itemName.close();
    _order.close();
    _itemsCounter.close();
    _isReadyToEdit.close();

    _orderListener.cancel();

    super.dispose();
  }
}
