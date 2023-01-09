import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/model/note.dart';

class NoteDTO extends DataTransferObject {
  Note note;

  NoteDTO({
    @required this.note,
  }) : assert(note != null);

  @override
  Future fromJson(json) {
    // TODO: implement fromJson
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "tipo": note.itemType,
      "texto": note.note,
    };
  }
}
