import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';

class LaudoOptionDTO extends DataTransferObject  {
  @override
  Future<List<LaudoOption>> fromJson(dynamic json) async {
    //final maps = json.toList();
    final laudoOptions = List<LaudoOption>();

    for (var options in json) {
      for (var option in options["options"]) {
        laudoOptions.add(
              LaudoOption(
                laudoType: options["laudo_type"],
                type: option["type"],
                subtype: option["subtype"],
                value: option["value"],
              ),
            );
      }
    }
    
    return laudoOptions;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }
}