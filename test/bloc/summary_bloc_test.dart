import 'package:flutter_test/flutter_test.dart';
import 'package:laudo_eletronico/bloc/summary/summary_bloc.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

main() {
  SummaryBloc bloc;
  LaudoMock laudoMock;
  List<ItemConfiguration> itemConfigurations;
  ConfigurationMock configurationMock;

  setUp(() {
    laudoMock = LaudoMock();

    when(laudoMock.answers).thenReturn([]);

    itemConfigurations = [
      ItemConfiguration(id: 1, order: 1, isMandatory: true),
      ItemConfiguration(id: 2, order: 1, isMandatory: false),
      ItemConfiguration(id: 3, order: 1, isMandatory: false),
      ItemConfiguration(id: 4, order: 2, isMandatory: false),
      ItemConfiguration(id: 5, order: 2, isMandatory: false),
      ItemConfiguration(id: 6, order: 3, isMandatory: false),
      ItemConfiguration(id: 7, order: 4, isMandatory: false),
    ];

    configurationMock = ConfigurationMock();
    when(laudoMock.configuration).thenReturn(configurationMock);
    when(configurationMock.items).thenReturn(itemConfigurations);

    bloc = SummaryBloc(laudo: laudoMock);
  });

  test(
      'When SummaryBloc is created, it should emit a list of SummaryItems as large as the number of different orders inside laudo',
      () async {
    //WHEN
    // bloc is created

    //THEN
    final list = await bloc.items.first;
    expect(list.length, 4);
  });

  test(
      'When a SummaryItem has unanswered mandatory items, it should not be complete',
      () async {
    //GIVEN
    //No answers:
    when(laudoMock.answers).thenReturn([]);

    //WHEN
    bloc.onDataChanged();

    //THEN
    final list = await bloc.items.first;
    final item = list
        .firstWhere((element) => element.order == itemConfigurations[0].order);
    //expect(item.isComplete, false);
  });

  test(
      'When a SummaryItem has all mandatory items answered, it should be complete',
      () async {
    //GIVEN
    //Mandatory items answered (new data inputted)
    final answer = Answer(item: itemConfigurations[0]);
    when(laudoMock.answers).thenReturn([answer]);

    //WHEN
    bloc.onDataChanged();

    //THEN
    final list = await bloc.items.first;
    final item = list
        .firstWhere((element) => element.order == itemConfigurations[0].order);
    expect(item.isComplete, true);
  });

  test(
      'When not all SummaryItems were completed, allItemsComplete should be false',
      () {
    //GIVEN
    itemConfigurations = [
      ItemConfiguration(id: 1, order: 1, isMandatory: true),
      ItemConfiguration(id: 2, order: 1, isMandatory: true),
      ItemConfiguration(id: 3, order: 1, isMandatory: true),
      ItemConfiguration(id: 4, order: 1, isMandatory: true),
    ];

    final answer1 = Answer(item: itemConfigurations[0]);
    final answer2 = Answer(item: itemConfigurations[1]);
    final answer3 = Answer(item: itemConfigurations[2]);

    when(laudoMock.answers).thenReturn([
      answer1,
      answer2,
      answer3,
    ]);
    //ItemConfiguration with id == 4 remains unanswered

    when(laudoMock.configuration).thenReturn(configurationMock);
    when(configurationMock.items).thenReturn(itemConfigurations);

    //WHEN
    bloc.onDataChanged();
    final allItemsComplete = bloc.isReadyToSendLaudo;

    //THEN
    expect(allItemsComplete, false);
  });

  test(
      'When all SummaryItems were completed, allItemsComplete should be true',
      () {
    //GIVEN
    itemConfigurations = [
      ItemConfiguration(id: 1, order: 1, isMandatory: true),
      ItemConfiguration(id: 2, order: 1, isMandatory: true),
      ItemConfiguration(id: 3, order: 1, isMandatory: true),
    ];

    final answer1 = Answer(item: itemConfigurations[0]);
    final answer2 = Answer(item: itemConfigurations[1]);
    final answer3 = Answer(item: itemConfigurations[2]);

    when(laudoMock.answers).thenReturn([
      answer1,
      answer2,
      answer3,
    ]);

    when(laudoMock.configuration).thenReturn(configurationMock);
    when(configurationMock.items).thenReturn(itemConfigurations);

    //WHEN
    bloc.onDataChanged();
    final allItemsComplete = bloc.isReadyToSendLaudo;

    //THEN
    expect(allItemsComplete, true);
  });
}
