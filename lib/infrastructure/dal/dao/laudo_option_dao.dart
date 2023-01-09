import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';

class LaudoOptionDAO extends DataAccessObject<LaudoOption> {
  @override
  String get tableName => "LAUDO_OPTION";

  @override
  List<Column> get columns => [
        this.columnId,
        this.columnLaudoType,
        this.columnType,
        this.columnSubType,
        this.columnValue,
      ];

  @override
  LaudoOption fromMap(Map<String, dynamic> map) {
    return LaudoOption(
      id: map[this.columnId.name],
      laudoType: map[this.columnLaudoType.name],
      type: map[this.columnType.name],
      subtype: map[this.columnSubType.name],
      value: map[this.columnValue.name],
    );
  }

  @override
  Map<String, dynamic> toMap(LaudoOption laudoOption) {
    return {
      this.columnId.name: laudoOption.id,
      this.columnLaudoType.name: laudoOption.laudoType,
      this.columnType.name: laudoOption.type,
      this.columnSubType.name: laudoOption.subtype,
      this.columnValue.name: laudoOption.value,
    };
  }

  final columnId = const Column(
    name: "ID",
    type: ColumnTypes.Int,
    isPrimaryKey: true,
    canBeNull: false,
  );
  final columnLaudoType = const Column(name: "LAUDO_TYPE", type: ColumnTypes.Text);
  final columnType = const Column(name: "TYPE", type: ColumnTypes.Text);
  final columnSubType = const Column(name: "SUB_TYPE", type: ColumnTypes.Text);
  final columnValue = const Column(name: "VALUE", type: ColumnTypes.Text);
}
