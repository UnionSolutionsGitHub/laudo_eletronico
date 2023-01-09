import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/input_type.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';

class ItemConfigurationDAO extends DataAccessObject<ItemConfiguration> {
  @override
  String get tableName => "ITEM_CONFIGURATION";

  @override
  List<Column> get columns => [
        columnId,
        columnConfigurationId,
        columnKey,
        columnDescption,
        columnType,
        columnSubType,
        columnInputType,
        columnIsMandatory,
        columnIsNotApplicable,
        columnOrder,
      ];

  @override
  ItemConfiguration fromMap(Map<String, dynamic> map) {
    return ItemConfiguration(
      id: map[columnId.name],
      key: map[columnKey.name],
      descption: map[columnDescption.name],
      isMandatory: map[columnIsMandatory.name] == 1,
      isNotApplicable: map[columnIsNotApplicable.name] == 1,
      type: map[columnType.name],
      subtype: map[columnSubType.name],
      inputType: inputTypeFor(map[columnInputType.name]),
      order: map[columnOrder.name],
    );
  }

  @override
  Map<String, dynamic> toMap(ItemConfiguration item) {
    return {
      columnId.name: item.id,
      columnConfigurationId.name: item.configuration.id,
      columnKey.name: item.key,
      columnDescption.name: item.descption,
      columnType.name: item.type,
      columnSubType.name: item.subtype,
      columnInputType.name: nameFor(item.inputType),
      columnIsMandatory.name: item.isMandatory,
      columnIsNotApplicable.name: item.isNotApplicable,
      columnOrder.name: item.order,
    };
  }

  final columnId = const Column(name: "ID", type: ColumnTypes.Int, isPrimaryKey: true, isAutoincrement: true);
  final columnConfigurationId = const Column(name: "CONFIGURATION_ID", type: ColumnTypes.Int, canBeNull: false);
  final columnKey = const Column(name: "KEY", type: ColumnTypes.Text);
  final columnDescption = const Column(name: "DESCRIPTION", type: ColumnTypes.Text);
  final columnType = const Column(name: "TYPE", type: ColumnTypes.Text);
  final columnSubType = const Column(name: "SUB_TYPE", type: ColumnTypes.Text);
  final columnInputType = const Column(name: "INPUT_TYPE", type: ColumnTypes.Text);
  final columnOrder = const Column(name: "ORDER_NUMBER", type: ColumnTypes.Int);
  final columnIsMandatory = const Column(name: "IS_MANDATORY", type: ColumnTypes.Boolean);
  final columnIsNotApplicable = const Column(name: "IS_NOT_APPLICABLE", type: ColumnTypes.Boolean);
}
