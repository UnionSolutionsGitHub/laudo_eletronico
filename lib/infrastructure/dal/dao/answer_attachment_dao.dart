import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/answer_attachment.dart';

class AnswerAttachmentDAO extends DataAccessObject<AnswerAttachment> {
  @override
  String get tableName => "ANSWER_ATTACHMENT";
  @override
  List<Column> get columns => [
        this.columnId,
        this.columnAnswerId,
        this.columnPath,
        this.columnUrl,
      ];

  @override
  AnswerAttachment fromMap(Map<String, dynamic> map) {
    return AnswerAttachment(
      id: map[this.columnId.name],
      path: map[this.columnPath.name],
      url: map[this.columnUrl.name],
    );
  }

  @override
  Map<String, dynamic> toMap(AnswerAttachment attachment) {
    return {
      this.columnId.name: attachment.id,
      this.columnAnswerId.name: attachment.answer.id,
      this.columnPath.name: attachment.path,
      this.columnUrl.name: attachment.url,
    };
  }

  final columnId = const Column(
    name: "ID",
    type: ColumnTypes.Int,
    isPrimaryKey: true,
    canBeNull: false,
    isAutoincrement: true,
  );
  final columnAnswerId = const Column(
    name: "ANSWER_ID",
    type: ColumnTypes.Int,
    canBeNull: false,
  );
  final columnPath = const Column(
    name: "PATH",
    type: ColumnTypes.Text,
  );
  final columnUrl = const Column(
    name: "URL",
    type: ColumnTypes.Text,
  );
}
