import 'package:collection/collection.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';

import 'laudo.dart';

/// Represents a visual item shown in SummaryView.
class SummaryItem {
  int id;
  final int order;
  List<ItemConfiguration> itemConfigurations;
  SummaryItemStatus status;
  Laudo laudo;

  SummaryItem({
    this.id,
    this.order,
    this.itemConfigurations,
    this.status,
    this.laudo,
  });

  static List<SummaryItem> listFrom({Laudo laudo}) {
    final orderMap = groupBy(
      laudo.configuration.items,
      (ItemConfiguration item) => item.order,
    );

    final summaryItems = <SummaryItem>[];

    for (var order in orderMap.keys) {
      final item = SummaryItem(
        order: order,
        itemConfigurations: orderMap[order],
        laudo: laudo,
        status: SummaryItemStatus.notVisited,
      );
      summaryItems.add(item);
    }
    return summaryItems;
  }
}

enum SummaryItemStatus {
  notVisited, // The item was not even visited by the user yet
  incomplete, // The item was visited but there are still some unanswered mandatory elements
  acceptable, // The item was visited and all mandatory elements were answered
  complete, // The item was fully answered
}
