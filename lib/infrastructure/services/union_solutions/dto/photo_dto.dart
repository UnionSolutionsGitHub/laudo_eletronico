import 'package:laudo_eletronico/infrastructure/services/service_base.dart';

class PhotoDTO extends DataTransferObject {
  String base64photo;

  PhotoDTO({
    this.base64photo,
  });

  @override
  Future<String> fromJson(dynamic json) async {
    String s = json["url"];
    return s;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "foto": base64photo,
    };
  }
}
