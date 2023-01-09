import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_option_dao.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_contract.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_view.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist_alert_list/laudo_checklist_alert_list_view.dart';
import 'package:laudo_eletronico/presentation/laudo_concluido/laudo_concluido_view.dart';

class LaudoChecklistPresenter implements LaudoChecklistPresenterContract {
  LaudoChecklistViewContract _view;
  Laudo laudo;
  bool _isLoading = true, _canGoNextStep, _isLastStep;
  String _appBarTitleStringKey, _laudoType;

  //List<LaudoOption> _laudoOkOptions, _laudoAlertOptions, _laudoRiskOptions;
  List<LaudoOption> _laudoOptions;
  bool _showOkButton, _showAlertButton, _showRiskButton;

  LaudoChecklistPresenter(this._view, this.laudo, this._laudoType) {
    switch (_laudoType) {
      case ItemConfigurationType.PINTURA:
        _isLastStep = false;
        _appBarTitleStringKey = "laudo_descritivo_painting_title";
        _canGoNextStep = laudo.isPaintingDone;
        break;
      case ItemConfigurationType.ESTRUTURA:
        _isLastStep = false;
        _appBarTitleStringKey = "laudo_descritivo_structure_title";
        _canGoNextStep = laudo.isStructureDone;
        break;
      case ItemConfigurationType.IDENTIFICACAO:
        _isLastStep = true;
        _appBarTitleStringKey = "laudo_descritivo_identify_title";
        _canGoNextStep = laudo.isIdentifyDone;
        break;
    }

    _init();
  }

  _init() async {
    _checkCanGoNextStep();
    await _loadChecksAnswers();
    _isLoading = false;
    _view.notifyDataChanged();
  }

  @override
  String get appBarTitleStringKey => _appBarTitleStringKey;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get showOkButton => _showOkButton;

  @override
  bool get showAlertButton => _showAlertButton;

  @override
  bool get showRiskButton => _showRiskButton;

  @override
  bool get canGoNextStep => _canGoNextStep;

  @override
  bool get isLastStep => _isLastStep;

  @override
  String get laudoType => _laudoType;

  @override
  List<ItemConfiguration> get items => laudo.configuration.items.where((item) => item.type == _laudoType).toList();

  @override
  bool isAnswered(ItemConfiguration item) {
    return laudo?.answers?.any((answer) => answer?.item?.id == item?.id) == true ?? false;
  }

  @override
  bool checkAnswered(ItemConfiguration item, String answerType) {
    return laudo?.answers?.any(
              (answer) =>
                  answer?.item?.id == item?.id &&
                  (_laudoOptions.any(
                        (option) => option.type == answerType && option.value == answer.value,
                      ) ||
                      answer.value == answerType),
            ) ==
            true ??
        false;
  }

  @override
  onAnswerClickListener(ItemConfiguration item, String answerType) async {
    final answerValue = await _getAnswer(item, answerType);

    if (answerValue?.isNotEmpty != true) {
      return;
    }

    Answer answer = _answer(item, answerValue);

    await _saveAnswer(answer);

    _checkCanGoNextStep();
    _view.notifyDataChanged();
  }

  @override
  onAnswerText(ItemConfiguration item, String answerValue) async {
    Answer answer = _answer(item, answerValue);
    await _saveAnswer(answer);
    _checkCanGoNextStep();
  }

  Answer _answer(ItemConfiguration item, String answerValue) {
    final answer = laudo?.answers?.any((answer) => answer?.item?.id == item?.id) == true ? laudo?.answers?.singleWhere((answer) => answer?.item?.id == item?.id) : Answer();

    answer.item = item;
    answer.laudo = laudo;
    answer.value = answerValue;
    return answer;
  }

  Future _saveAnswer(Answer answer) async {
    final answerDao = AnswerDAO();

    if (answer.id != null && answer.id > 0) {
      if (answer?.value?.isEmpty == true) {
        await answerDao.delete({
          answerDao.columnId: answer.id,
        });

        laudo.answers.removeWhere((a) => a.id == answer.id);

        return;
      }

      await answerDao.update(answer);
    } else {
      answer.id = await answerDao.insert(answer);
      laudo.answers.add(answer);
    }
  }

  @override
  onBtnNextSteapClickListener() {
    if (_canGoNextStep != true) {
      _view.showAlertCantGoNextStep();
      return;
    }

    if (_laudoType == ItemConfigurationType.IDENTIFICACAO) {
      if (laudo.isPhotoDone != true || laudo.isPaintingDone != true || laudo.isStructureDone != true || laudo.isIdentifyDone != true) {
        _view.showAlertCantGoNextStep();
        return;
      }

      _view.navigatorPush(
        MaterialPageRoute(
          builder: (BuildContext context) => LaudoConcluidoView(laudo),
        ),
      );

      return;
    }

    if (_laudoType == ItemConfigurationType.PINTURA) {
      _view.navigatorPush(
        MaterialPageRoute(
          builder: (BuildContext context) => LaudoChecklistView(laudo, ItemConfigurationType.ESTRUTURA),
        ),
      );

      return;
    }

    _view.navigatorPush(
      MaterialPageRoute(
        builder: (BuildContext context) => LaudoChecklistView(laudo, ItemConfigurationType.IDENTIFICACAO),
      ),
    );
  }

  Future<String> _getAnswer(ItemConfiguration item, String answerType) async {
    final options = _laudoOptions.where((option) => option.laudoType == _laudoType && option.type == answerType && option.subtype == item.subtype).toList();

    if (options.length <= 0) {
      return answerType;
    }

    if (options.length == 1) {
      return options.first.value;
    }

    final selectedOption = await _view.navigatorPushAwaitForResult(LaudoChecklistAlertListView(options));

    return selectedOption?.value;
  }

  Future _loadChecksAnswers() async {
    _laudoOptions = await LaudoOptionDAO().get();

    _showOkButton = _laudoOptions.any(
      (option) => option.laudoType == _laudoType && option.type == LaudoOptionTypes.OK,
    );
    _showAlertButton = _laudoOptions.any(
      (option) => option.laudoType == _laudoType && option.type == LaudoOptionTypes.Alert,
    );
    _showRiskButton = _laudoOptions.any(
      (option) => option.laudoType == _laudoType && option.type == LaudoOptionTypes.Risk,
    );
  }

  _checkCanGoNextStep() {
    final mandatoryItems = laudo.configuration.items.where((item) => item.type == _laudoType && item.isMandatory);

    for (var item in mandatoryItems) {
      if (!laudo.answers.any((answer) => answer.item.id == item.id)) {
        _canGoNextStep = false;
        _updateLaudo();
        return;
      }
    }

    _canGoNextStep = true;
    _updateLaudo();
  }

  _updateLaudo() async {
    switch (_laudoType) {
      case ItemConfigurationType.PINTURA:
        if (laudo.isPaintingDone != _canGoNextStep) {
          final laudoDao = LaudoDAO();

          laudo.isPaintingDone = _canGoNextStep;
          await laudoDao.update(laudo);
        }
        break;
      case ItemConfigurationType.ESTRUTURA:
        if (laudo.isStructureDone != _canGoNextStep) {
          final laudoDao = LaudoDAO();

          laudo.isStructureDone = _canGoNextStep;
          await laudoDao.update(laudo);
        }
        break;
      case ItemConfigurationType.IDENTIFICACAO:
        if (laudo.isIdentifyDone != _canGoNextStep) {
          final laudoDao = LaudoDAO();

          laudo.isIdentifyDone = _canGoNextStep;
          await laudoDao.update(laudo);
        }
        break;
      default:
    }
  }

  @override
  String textAnswer(ItemConfiguration item) {
    if (laudo?.answers?.any(
          (answer) => answer?.item?.id == item?.id,
        ) !=
        true) {
      return "";
    }

    return laudo?.answers
            ?.firstWhere(
              (answer) => answer?.item?.id == item?.id,
            )
            ?.value ??
        "";
  }

  int get laudoId => laudo.id;
}
