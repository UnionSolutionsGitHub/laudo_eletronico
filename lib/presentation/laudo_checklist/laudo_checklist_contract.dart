import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';

abstract class LaudoChecklistViewContract {
  notifyDataChanged();
  navigatorPush(MaterialPageRoute route);
  Future<LaudoOption> navigatorPushAwaitForResult(Widget route);
  showAlertCantGoNextStep();
}

abstract class LaudoChecklistPresenterContract {
  bool get isLoading;
  bool get canGoNextStep;
  String get appBarTitleStringKey;
  String get laudoType;
  List<ItemConfiguration> get items;
  bool get isLastStep;
  bool get showOkButton;
  bool get showAlertButton;
  bool get showRiskButton;
  int get laudoId;
  
  onBtnNextSteapClickListener();
  bool isAnswered(ItemConfiguration item);
  bool checkAnswered(ItemConfiguration item, String answerType);
  onAnswerClickListener(ItemConfiguration item, String answerValue);
  onAnswerText(ItemConfiguration item, String answerValue);
  String textAnswer(ItemConfiguration item);
}