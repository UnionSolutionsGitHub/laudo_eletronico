import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/model/answer.dart';

class AnswerDTO extends DataTransferObject<Answer> {
  Answer answer;

  AnswerDTO({
    this.answer,
  });

  @override
  Future<Answer> fromJson(dynamic json) {
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "tipo": answer.item.type,
      "idPergunta": answer.item.key,
      "resposta": answer.value,
   };
  }
}
