import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';

class AnswerDAO extends DataAccessObject<Answer> {
  @override
  String get tableName => "ANSWER";
  @override
  List<Column> get columns => [
        columnId,
        columnLaudoId,
        columnConfigurationItemId,
        columnValue,
      ];

  @override
  Answer fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map[columnId.name],
      item: ItemConfiguration(id: map[columnConfigurationItemId.name]),
      value: map[columnValue.name],
    );
  }

  @override
  Map<String, dynamic> toMap(Answer answer) {
    return {
      columnId.name: answer.id,
      columnLaudoId.name: answer.laudo.id,
      columnConfigurationItemId.name: answer.item.id,
      columnValue.name: answer.value,
    };
  }

  final columnId = const Column(
    name: "ID",
    type: ColumnTypes.Int,
    isPrimaryKey: true,
    canBeNull: false,
    isAutoincrement: true,
  );
  final columnLaudoId = const Column(
    name: "LAUDO_ID",
    type: ColumnTypes.Int,
    canBeNull: false,
  );
  final columnConfigurationItemId = const Column(
    name: "CONFIGURATION_ITEM_ID",
    type: ColumnTypes.Int,
    canBeNull: false,
  );
  final columnValue = const Column(
    name: "VALUE",
    type: ColumnTypes.Text,
  );
}
