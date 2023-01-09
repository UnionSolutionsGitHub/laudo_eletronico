import 'package:laudo_eletronico/model/answer.dart';

class AnswerAttachment {
  int id;
  String path, url;
  Answer answer;

  AnswerAttachment({
    this.id,
    this.path,
    this.url,
    this.answer,
  });
}
