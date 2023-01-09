import 'package:laudo_eletronico/model/answer_attachment.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/laudo.dart';

class Answer {
  int id;
  String value;
  Laudo laudo;
  ItemConfiguration item;
  AnswerAttachment attachment;
  
  Answer({
    this.id,
    this.value,
    this.laudo,
    this.item,
    this.attachment,
  });
}