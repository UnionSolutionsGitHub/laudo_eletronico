import 'input_type.dart';

class CheckItem {
  String description, checkedItem, type;
  InputType inputType;
  
  bool showOkButton = false,
      showAlertButton = false,
      showRiskButton = false,
      showNAButton = false;

  CheckItem({
    this.description,
    this.checkedItem,
    this.type,
    this.inputType,
    this.showOkButton,
    this.showAlertButton,
    this.showRiskButton,
    this.showNAButton,
  });

  String get placeholder {
    switch (inputType) {
      case InputType.date:
        return "Mês/Ano";
      default:
        return description;
    }
  }
}