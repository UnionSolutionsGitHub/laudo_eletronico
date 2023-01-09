import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/note.dart';

class NoteDAO extends DataAccessObject<Note> {
  @override
  String get tableName => "NOTES";

  @override
  List<Column> get columns => [
        columnId,
        columnLaudoId,
        columnLaudoType,
        columnNote,
      ];

  @override
  Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map[columnId.name],
      laudoId: map[columnLaudoId.name],
      itemType: map[columnLaudoType.name],
      note: map[columnNote.name],
    );
  }

  @override
  Map<String, dynamic> toMap(Note note) {
    return {
      columnId.name: note.id,
      columnLaudoId.name: note.laudoId,
      columnLaudoType.name: note.itemType,
      columnNote.name: note.note,
    };
  }

  final columnId = const Column(
    name: "ID",
    type: ColumnTypes.Int,
    isPrimaryKey: true,
    isAutoincrement: true,
  );
  final columnLaudoId = const Column(name: "LAUDO_ID", type: ColumnTypes.Int);
  final columnLaudoType = const Column(name: "LAUDO_TYPE", type: ColumnTypes.Text);
  final columnNote = const Column(name: "NOTE", type: ColumnTypes.Text);
}
