import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/input_type.dart';

class ItemConfiguration {
  int id, order;
  String key, descption, type, subtype;
  InputType inputType;
  bool isMandatory, isNotApplicable;

  Configuration configuration;

  ItemConfiguration({
    this.id,
    this.key,
    this.descption,
    this.isMandatory,
    this.isNotApplicable,
    this.type,
    this.subtype,
    this.inputType,
    this.configuration,
    this.order,
  });

    String get placeholder {
    switch (inputType) {
      case InputType.date:
        return "Mês/Ano";
      default:
        return "";
    }
  }
}
