import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';

class AdditionalPhotoDTO extends DataTransferObject<AdditionalPhoto> {
  AdditionalPhoto additionalPhoto;

  AdditionalPhotoDTO({
    this.additionalPhoto,
  });

  @override
  Future<AdditionalPhoto> fromJson(dynamic json) {
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "descricao": additionalPhoto.description,
      "url": additionalPhoto.url
    };
  }
}
