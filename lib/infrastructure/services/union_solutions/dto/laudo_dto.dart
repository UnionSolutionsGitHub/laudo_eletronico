import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/additional_photo_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/answer_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/note_dto.dart';
import 'package:laudo_eletronico/model/laudo.dart';

class LaudoDTO extends DataTransferObject<Laudo> {
  Laudo laudo;

  LaudoDTO({
    this.laudo,
  });

  @override
  Future<Laudo> fromJson(dynamic json) {
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": laudo.foreignId,
      "idCliente": laudo?.configuration?.client?.id,
      "idConfiguracao": laudo.configuration.id,
      "placa": laudo.carPlate,
      "chassi": laudo.chassi,
      "motor": laudo.engineNumber,
      "quilometragem": laudo.mileage,
      "dataCriacao": laudo.date.millisecondsSinceEpoch,
      "respostas": laudo.answers.map((answer) => AnswerDTO(answer: answer).toJson()).toList(),
      "fotosAdicionais": laudo.additionalPhotos.map((photo) => AdditionalPhotoDTO(additionalPhoto: photo).toJson()).toList(),
      "observacoes": laudo.notes.map((note) => NoteDTO(note: note)).toList(),
    };
  }
}
