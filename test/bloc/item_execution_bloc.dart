import 'package:flutter_test/flutter_test.dart';
import 'package:laudo_eletronico/bloc/item_execution/item_execution_bloc.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

main() {
  //ItemExecutionBloc bloc;
  LaudoMock laudoMock;

  setUp(() {
    laudoMock = LaudoMock();
  });

  test(
    'when set order and answer not exists then return new instance',
    () {
      final configurationItem =
          ItemConfiguration(id: 1, type: ItemConfigurationType.FOTO, order: 3);
      final configuration = Configuration(items: [configurationItem]);

      when(laudoMock.configuration).thenReturn(configuration);
      when(laudoMock.answers).thenReturn([]);

      final bloc = ItemExecutionBloc(laudo: laudoMock, order: 3);

      expect(bloc.photoStream, emits(isInstanceOf<Answer>()));
    },
  );

  test("when set order and answer exists then return that answer", () {
    final configurationItemPhoto =
        ItemConfiguration(id: 1, type: ItemConfigurationType.FOTO, order: 3);
    final configurationItemPainting =
        ItemConfiguration(id: 2, type: ItemConfigurationType.PINTURA, order: 3);
    final configurationItemStructure = ItemConfiguration(
        id: 3, type: ItemConfigurationType.ESTRUTURA, order: 3);
    final configurationItemIdentification = ItemConfiguration(
        id: 4, type: ItemConfigurationType.IDENTIFICACAO, order: 3);

    final photo = Answer(item: configurationItemPhoto);
    final painting = Answer(item: configurationItemPainting);
    final structure = Answer(item: configurationItemStructure);
    final identification = Answer(item: configurationItemIdentification);

    final configuration = Configuration(items: [
      configurationItemPhoto,
      configurationItemPainting,
      configurationItemStructure,
      configurationItemIdentification
    ]);

    when(laudoMock.configuration).thenReturn(configuration);
    when(laudoMock.answers)
        .thenReturn([photo, painting, structure, identification]);

    final bloc = ItemExecutionBloc(laudo: laudoMock, order: 3);

    expect(bloc.photoStream, emits(photo));
    expect(bloc.paintingStream, emits(painting));
    expect(bloc.structureStream, emits(structure));
    expect(bloc.identificationStream, emits(identification));
  });

  test("when no order passed find first element", () {
    final configuration = Configuration(items: [
      ItemConfiguration(id: 1, type: ItemConfigurationType.FOTO, order: 3)
    ]);

    when(laudoMock.configuration).thenReturn(configuration);
    when(laudoMock.answers).thenReturn([]);

    final bloc = ItemExecutionBloc(laudo: laudoMock);

    expect(bloc.photoStream, emits(isInstanceOf<Answer>()));
  });

  /* test("when laudoOption exists show button for that option", () {
    final configuration = Configuration(items: [ItemConfiguration(id: 1, type: ItemConfigurationType.FOTO, order: 3)]);

    when(laudoMock.configuration).thenReturn(configuration);
    when(laudoMock.answers).thenReturn([]);

    final bloc = ItemExecutionBloc(laudo: laudoMock, laudoOptions: [LaudoOption(laudoType: ItemConfigurationType.PINTURA, type: LaudoOptionTypes.OK)]);
    
    expect(bloc.showPaintingOkButton, true);
  });

  test("when laudoOption do not exists don't show button for that option", () {
    final configuration = Configuration(items: [ItemConfiguration(id: 1, type: ItemConfigurationType.FOTO, order: 3)]);

    when(laudoMock.configuration).thenReturn(configuration);
    when(laudoMock.answers).thenReturn([]);

    final bloc = ItemExecutionBloc(laudo: laudoMock, laudoOptions: [LaudoOption(laudoType: ItemConfigurationType.PINTURA, type: LaudoOptionTypes.OK)]);
    
    expect(bloc.showPaintingAlertButton, false);
  }); */
}
