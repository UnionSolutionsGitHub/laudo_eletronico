import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/summary_item.dart';

import '../database_helper.dart';

class SummaryItemDAO extends DataAccessObject<SummaryItem> {
  @override
  String get tableName => "SUMMARY_ITEM";
  @override
  List<Column> get columns => [
    columnId,
        columnLaudoId,
        columnOrder,
        columnStatus,
      ];

  @override
  SummaryItem fromMap(Map<String, dynamic> map) {
    return SummaryItem(
      id: map[columnId.name],
      laudo: Laudo(id: map[columnLaudoId.name]),
      order: map[columnOrder.name],
      status: SummaryItemStatus.values[map[columnStatus.name]],
    );
  }

  @override
  Map<String, dynamic> toMap(SummaryItem item) {
    return {
      columnId.name: item.id,
      columnLaudoId.name: item?.laudo?.id,
      columnOrder.name: item?.order,
      columnStatus.name: item?.status?.index,
    };
  }

  final columnId = const Column(name: "ID", type: ColumnTypes.Int, isPrimaryKey: true, isAutoincrement: true);
  final columnLaudoId = const Column(name: "LAUDO_ID", type: ColumnTypes.Int);
  final columnOrder = const Column(name: "ITEM_ORDER", type: ColumnTypes.Int);
  final columnStatus = const Column(name: "STATUS", type: ColumnTypes.Int);
}
