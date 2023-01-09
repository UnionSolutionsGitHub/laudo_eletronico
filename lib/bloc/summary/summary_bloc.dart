import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:laudo_eletronico/bloc/grid_view/grid_view_bloc.dart';
import 'package:laudo_eletronico/bloc/item_execution/item_execution_bloc.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_option_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/summary_item_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/summary_item.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import "package:collection/collection.dart";

class SummaryBloc extends GridViewBloc {
  Laudo laudo;

  final _items = BehaviorSubject<List<SummaryItem>>();
  final _isSendButtonVisible = BehaviorSubject<bool>.seeded(false);
  bool isReadyToSendLaudo = false;

  //
  // Inputs
  //
  /// Called when [laudo] data was potencially changed (when arriving at SummaryView from another page,
  /// via Navigator.pop() for example).
  Function get onDataChanged => _buildListOfSummaryItems;

  onScroll(ScrollPosition position) {
    if (position.userScrollDirection == ScrollDirection.reverse) {
      if (_isSendButtonVisible.value != false) _isSendButtonVisible.add(false);
    } else if (position.userScrollDirection == ScrollDirection.forward &&
        isReadyToSendLaudo) {
      if (_isSendButtonVisible.value != true) _isSendButtonVisible.add(true);
    }
  }

  //
  // Outputs
  //
  @override
  double get cardAspectRatio => cardWidth / cardHeight;

  @override
  double get cardHeight => cardWidth * 1.2;

  Stream<List<SummaryItem>> get items => _items.stream;

  Stream<bool> get isSendButtonVisible => _isSendButtonVisible.stream;

  //
  // Constructor
  //
  SummaryBloc({@required this.laudo}) : assert(laudo != null) {
    _buildListOfSummaryItems();
  }

  /// Given a list of ItemConfigurations [laudo.configuration.items], groups the items with the same
  /// order in an object called [SummaryItem].
  /// Creates a list of such SummaryItems and add that list to the [_items.stream].
  _buildListOfSummaryItems() async {
    List<SummaryItem> list;

    final orderMap = groupBy(
      laudo.configuration.items,
      (ItemConfiguration item) => item.order,
    );

    list = await _getSummaryItemsFromDatabase(orderMap);
    if (list == null || list.isEmpty) {
      list = await _buildNewSummaryItems(laudo);
    }

    list.any((item) =>
            item.status == SummaryItemStatus.incomplete ||
            item.status == SummaryItemStatus.notVisited)
        ? isReadyToSendLaudo = false
        : isReadyToSendLaudo = true;

    _isSendButtonVisible.add(isReadyToSendLaudo);

    _items.add(list);
  }

  /// Retrieves a list of [SummaryItem] from the database for this [laudo], if there are any
  /// already saved.
  Future<List<SummaryItem>> _getSummaryItemsFromDatabase(
      Map<int, List<ItemConfiguration>> orderMap) async {
    final dao = SummaryItemDAO();
    List<SummaryItem> summaryItems = await dao.get(
      args: {
        dao.columnLaudoId: laudo.id,
      },
    );
    for (var item in summaryItems) {
      item.itemConfigurations = orderMap[item.order];
    }
    return summaryItems;
  }

  /// Builds a new list of [SummaryItem] for this [laudo], saves each one in the database and returns the list.
  Future<List<SummaryItem>> _buildNewSummaryItems(Laudo laudo) async {
    final summaryItems = SummaryItem.listFrom(laudo: laudo);
    final dao = SummaryItemDAO();
    for (var item in summaryItems) {
      final id = await dao.insert(item);
      item.id = id;
    }
    return summaryItems;
  }

  /// Returns this [item]'s photo path, if there is any.
  String photoPathFor(SummaryItem item) {
    final itemConfiguration = item.itemConfigurations.firstWhere(
        (item) => item.type == ItemConfigurationType.FOTO,
        orElse: () => null);
    final answer = laudo.answers?.firstWhere(
        (answer) => itemConfiguration?.id == answer.item.id,
        orElse: () => null);
    return answer?.attachment?.path ?? answer?.value;
  }

  /// Creates the Bloc for the next page that will be shown and returns it
  Future<ItemExecutionBloc> onItemClicked(SummaryItem item) async {
    final fileManager = await FileManager.instance;
    final laudoOptions = await LaudoOptionDAO().get();
    final bloc = ItemExecutionBloc(
      order: item.order,
      laudo: laudo,
      answerDAO: AnswerDAO(),
      fileManager: fileManager,
      service: UnionSolutionsService(),
      laudoOptions: laudoOptions,
      laudoDAO: LaudoDAO(),
      summaryItems: _items.value,
      answerAttachmentDAO: AnswerAttachmentDAO(),
    );
    return bloc;
  }

  @override
  void dispose() {
    _items.close();
    _isSendButtonVisible.close();
    super.dispose();
  }
}
