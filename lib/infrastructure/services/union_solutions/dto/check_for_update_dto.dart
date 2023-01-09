import 'package:laudo_eletronico/infrastructure/services/service_base.dart';

class CheckForUpdateDTO extends DataTransferObject {
  List<int> newConfigs, disableds, _ids;

  CheckForUpdateDTO(this._ids);

  @override
  Future<CheckForUpdateDTO> fromJson(dynamic json) async {
    this.newConfigs = json["new"]?.cast<int>()?.toList() ?? List<int>();
    this.disableds = json["disabled"]?.cast<int>()?.toList() ?? List<int>();
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "ids": _ids,
    };
  }

}