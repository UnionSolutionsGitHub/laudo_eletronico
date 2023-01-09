import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/item_execution/item_execution_bloc.dart';
import 'package:laudo_eletronico/bloc/photo_gallery/photo_gallery_bloc.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/client_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/item_configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_option_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/summary_item_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/summary_item.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_view.dart';
import 'package:laudo_eletronico/view/item_execution/item_execution_view.dart';
import 'package:laudo_eletronico/view/photo_gallery/photo_gallery_view.dart';
import './listagem_configuracoes_contract.dart';

class ListagemConfiguracoesPresenter
    implements ListagemConfiguracoesPresenterContract {
  ListagemConfiguracoesViewContract _view;
  Laudo _laudo;

  TextEditingController _queryController;
  List<Configuration> _configurations;
  List<Configuration> _filteredList;
  bool _isLoading;

  ListagemConfiguracoesPresenter(this._view, this._laudo) {
    _isLoading = true;
    _queryController = TextEditingController();
    _init();
  }

  _init() async {
    _configurations = List<Configuration>();

    final clientDao = ClientDAO();
    final localResources = await LocalResources().instance();
    final user = User.fromToken(localResources.token);

    /*final userConfigurationDao = UserConfigurationDAO();
    final configurationDao = ConfigurationDAO();

    final userConfigurations = await userConfigurationDao.get(args: {
      userConfigurationDao.columnUserId: user.id,
    }) as List<UserConfiguration>;

    _configurations = await configurationDao.get(args: {
      configurationDao.columnId: userConfigurations.map<int>((item) => item.configurationId).toList(),
    }) as List<Configuration>;

    final clients = await clientDao.get(args: {clientDao.columnId: _configurations.map((x) => x.client.id)});

    for (var client in clients) {
      client.user = user;
      _configurations.addAll(client.configurations);
    } */

    final clients = await clientDao.getWithConfiguration(user);

    for (var client in clients) {
      client.user = user;
      _configurations.addAll(client.configurations);
    }

    _configurations.sort((a, b) => a.client.name.compareTo(b.client.name));

    _filteredList = _configurations;
    _isLoading = false;
    _view.notifyDataChanged();
  }

  @override
  TextEditingController get queryController => _queryController;

  @override
  List<Configuration> get configurations => _filteredList;

  @override
  bool get isLoading => _isLoading;

  @override
  get onQueryChanged => _onQueryChanged;

  void _onQueryChanged(String query) {
    _filteredList = query.isEmpty
        ? _configurations
        : _configurations
            .where((configuration) =>
                configuration.client.name.startsWith(query.toUpperCase()))
            .toList();

    _view.notifyDataChanged();
  }

  @override
  onSelectedItemListener(int index) async {
    _isLoading = true;
    _view.notifyDataChanged();

    final laudoDao = LaudoDAO();
    final itemConfigurationDAO = ItemConfigurationDAO();

    _laudo.configuration = _filteredList[index];

    _laudo.configuration.items = await itemConfigurationDAO.get(
      args: {
        itemConfigurationDAO.columnConfigurationId: _laudo.configuration.id,
      },
      orderBy: itemConfigurationDAO.columnOrder,
    );

    _laudo.hasPhoto = _laudo.configuration.items
        .any((item) => item.type == ItemConfigurationType.FOTO);
    _laudo.hasPainting = _laudo.configuration.items
        .any((item) => item.type == ItemConfigurationType.PINTURA);
    _laudo.hasStructure = _laudo.configuration.items
        .any((item) => item.type == ItemConfigurationType.ESTRUTURA);
    _laudo.hasIdentify = _laudo.configuration.items
        .any((item) => item.type == ItemConfigurationType.IDENTIFICACAO);

    _laudo.isPaintingDone = !_laudo.hasPainting;
    _laudo.isStructureDone = !_laudo.hasStructure;
    _laudo.isIdentifyDone = !_laudo.hasIdentify;

    _laudo.id = await laudoDao.insert(_laudo);

    if (_laudo.isPhotoDone) {
      final nextStep = _laudo.configuration.items
              .any((item) => item.type == ItemConfigurationType.PINTURA)
          ? ItemConfigurationType.PINTURA
          : _laudo.configuration.items
                  .any((item) => item.type == ItemConfigurationType.ESTRUTURA)
              ? ItemConfigurationType.ESTRUTURA
              : null;

      if (nextStep == null) {
        laudoDao.delete({laudoDao.columnId: _laudo.id});
        return;
      }

      _view.navigatorPush(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              LaudoChecklistView(_laudo, nextStep),
        ),
        false,
      );

      _isLoading = false;
      _view.notifyDataChanged();

      return;
    }

    final localResources = await LocalResources().instance();
    final nextView = await _getNextView();
    _view.navigatorPush(
      MaterialPageRoute(builder: (BuildContext context) => nextView),
      localResources.isNewFlowEnabled ?? false,
    );
  }

  Future<Widget> _getNextView() async {
    final localResources = await LocalResources().instance();
    final fileManager = await FileManager.instance;
    final laudoOptions = await LaudoOptionDAO().get();
    Widget nextView;
    BlocBase bloc;

    // Create new summary items
      final summaryItems = SummaryItem.listFrom(laudo: _laudo);
      final dao = SummaryItemDAO();
      // Save each item on the database and get their ids
      for (var item in summaryItems) {
        final id = await dao.insert(item);
        item.id = id;
      }

    if (localResources.isNewFlowEnabled) {
      bloc = ItemExecutionBloc(
        laudo: _laudo,
        answerDAO: AnswerDAO(),
        fileManager: fileManager,
        service: UnionSolutionsService(),
        laudoOptions: laudoOptions,
        laudoDAO: LaudoDAO(),
        summaryItems: summaryItems,
        answerAttachmentDAO: AnswerAttachmentDAO(),
      );

      nextView = ItemExecutionView(bloc, true);
    } else {
      bloc = PhotoGalleryBloc(
        laudo: _laudo,
        fileManager: fileManager,
      );

      nextView = PhotoGalleryView(bloc, true);
    }
    return nextView;
  }
}
