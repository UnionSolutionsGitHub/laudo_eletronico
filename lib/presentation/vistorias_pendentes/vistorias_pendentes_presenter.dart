import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bll/agendamento_bo.dart';
import 'package:laudo_eletronico/bloc/summary/summary_bloc.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/additional_photo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/agendamento_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/item_configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/summary_item_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/model/answer_attachment.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/summary_item.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/presentation/laudo_sumario/laudo_sumario_view.dart';
import 'package:laudo_eletronico/presentation/nova_vistoria/nova_vistoria_view.dart';
import 'package:laudo_eletronico/view/summary/summary_view.dart';

import './vistorias_pendentes_contract.dart';

class VistoriasPendentesPresenter
    implements VistoriasPendentesPresenterContract {
  VistoriasPendentesViewContract _view;
  TextEditingController _queryController;
  List<Laudo> _laudos;
  List<Laudo> _filteredList;
  LocalResources localResources;
  LaudoDAO laudoDao;
  SummaryItemDAO _summaryItemDao;
  AgendamentoDAO agendamentoDao;
  List<SummaryItem> _summaryItems;
  bool _isLoading = true;

  VistoriasPendentesPresenter(this._view) {
    _queryController = TextEditingController();
    AgendamentoBO().addListener(_onLaudoAgendadoListener);
    _summaryItemDao = SummaryItemDAO();
    _init();
  }

  _init() async {
    _summaryItems = List();
    localResources = await LocalResources().instance();
    final user = User.fromToken(localResources.token);

    laudoDao = LaudoDAO();
    agendamentoDao = AgendamentoDAO();

    _laudos = await laudoDao.get(args: {laudoDao.columnUserId: user.id});

    for (var laudo in _laudos) {
      if (localResources.isNewFlowEnabled) {
        final summaryItems = await _summaryItemDao
            .get(args: {_summaryItemDao.columnLaudoId: laudo.id});
        _summaryItems.addAll(summaryItems);
      }

      if (laudo.foreignId == null) {
        continue;
      }

      laudo.agendamento = (await agendamentoDao.get(args: {
        agendamentoDao.columnLaudoId: laudo.foreignId,
      }))
          .first;
    }

    _filteredList = _laudos;
    _isLoading = false;
    _view.notifyDataChanged();
  }

  _onLaudoAgendadoListener() {
    this.reloadData();
  }

  @override
  dispose() {
    AgendamentoBO().removeListener(_onLaudoAgendadoListener);
  }

  @override
  bool get isLoading => _isLoading;

  @override
  TextEditingController get queryController => _queryController;

  @override
  List<Laudo> get laudos => _filteredList;

  @override
  get onQueryChanged => _onQueryChanged;

  void _onQueryChanged(String query) {
    _filteredList = query.isEmpty
        ? _laudos
        : _laudos
            .where((laudo) => laudo.carPlate.startsWith(query.toUpperCase()))
            .toList();

    this._view.notifyDataChanged();
  }

  @override
  String newFlowStatus(Laudo laudo) {
    final total =
        _summaryItems.where((summaryItem) => summaryItem.laudo.id == laudo.id);
    final completed = total.where(
        (summaryItem) => summaryItem.status == SummaryItemStatus.complete);
    return "${completed.length}/${total.length}";
  }

  clickActionFor(int index) async {
    Laudo laudo;

    _view.showProgressIndeterminate();

    _loadLaudoInformations(index).then((Laudo laudoWithInfos) {
      laudo = laudoWithInfos;
    }).whenComplete(() {
      _view.hideProgressIndeterminate();

      if (laudo == null) {
        return;
      }

      if (laudo?.carPlate?.isNotEmpty != true) {
        _view.navigatorPush(
          MaterialPageRoute(
            builder: (BuildContext context) => NovaVistoriaView(
              laudo: laudo,
              configMenu: ConfigurationMenuButton(),
            ),
          ),
        );

        return;
      }

      final isNewFlowEnabled = localResources.isNewFlowEnabled;
      _view.navigatorPush(
        MaterialPageRoute(
          builder: (BuildContext context) => isNewFlowEnabled ?? false
              ? SummaryView(
                  bloc: SummaryBloc(laudo: laudo),
                )
              : LaudoSumarioView(laudo),
        ),
      );
    });
  }

  @override
  reloadData() async {
    _isLoading = true;
    _init();
    _view.notifyDataChanged();
  }

  Future<Laudo> _loadLaudoInformations(int index) async {
    final laudo = _filteredList[index];
    final itemConfigurationDAO = ItemConfigurationDAO();
    final answerDao = AnswerDAO();
    final additionalPhotoDao = AdditionalPhotoDAO();
    final configurationDao = ConfigurationDAO();
    final answerAttachamentDao = AnswerAttachmentDAO();

    if (laudo.configuration.items == null) {
      laudo.configuration = (await configurationDao.get(
        args: {
          configurationDao.columnId: laudo.configuration.id,
        },
      ))
          ?.first;

      laudo.configuration.items = await itemConfigurationDAO.get(
        args: {
          itemConfigurationDAO.columnConfigurationId: laudo.configuration.id,
        },
        orderBy: itemConfigurationDAO.columnOrder,
      );

      laudo.answers = await answerDao.get(args: {
        answerDao.columnLaudoId: laudo.id,
      });

      for (var answer in laudo?.answers) {
        answer.item = laudo?.configuration?.items
            ?.firstWhere((item) => item.id == answer.item.id);
        answer.laudo = laudo;

        List<AnswerAttachment> attachs = await answerAttachamentDao.get(
          args: {
            answerAttachamentDao.columnAnswerId: answer.id,
          },
        );

        answer.attachment = attachs.length > 0 ? attachs.first : null;
      }
    }

    if (laudo.additionalPhotos == null) {
      laudo.additionalPhotos = await additionalPhotoDao.get(args: {
        additionalPhotoDao.columnLaudoId: laudo.id,
      });

      for (var additionalPhoto in laudo.additionalPhotos) {
        additionalPhoto.laudo = laudo;
      }
    }

    return laudo;
  }

  bool get isNewFlowEnabled => localResources.isNewFlowEnabled;

  final selectedItems = <int>[];
  bool isInSelectionMode = false;
  int get selectedCount => selectedItems.length;

  @override
  cancelSelection() {
    selectedItems.clear();
    isInSelectionMode = false;
    _view.notifyDataChanged();
  }

  @override
  Future<bool> deleteSelected() async {
    final laudosToBeDeleted =
        selectedItems.map((index) => _filteredList[index]).toList();

    final laudosDeleted = <Laudo>[];

    bool allWereDeletedSuccessfully = true;
    for (var laudo in laudosToBeDeleted) {
      final deleted = await _deleteLaudo(laudo);
      if (!deleted) {
        allWereDeletedSuccessfully = false;
      } else {
        laudosDeleted.add(laudo);
      }
    }

    //Remove delete laudos from the presenter list too
    laudosDeleted.forEach((laudo) => _filteredList.remove(laudo));

    cancelSelection();
    _view.notifyDataChanged();

    return allWereDeletedSuccessfully;
  }

  /// Tries to delete this laudo. If successful, return [true], otherwise return [false].
  Future<bool> _deleteLaudo(Laudo laudo) async {
    // Dont delete scheduled laudos with upcoming date:
    if (laudo.agendamento?.date?.isAfter(DateTime.now()) ?? false) return false;

    _summaryItemDao.delete({_summaryItemDao.columnLaudoId: laudo.id});
    
    if (laudo.agendamento != null) {
      agendamentoDao.delete({agendamentoDao.columnLaudoId: laudo.foreignId});
    }

    await laudoDao.deleteWithAnswers(laudo);
    return true;
  }

  @override
  onItemClicked(int index) {
    isInSelectionMode ? onChangeItemSelection(index) : clickActionFor(index);
  }

  @override
  onChangeItemSelection(int index) {
    if (!isItemSelected(index)) {
      //select item
      if (selectedItems.isEmpty) isInSelectionMode = true;
      selectedItems.add(index);
    } else {
      //deselect item
      selectedItems.remove(index);
      if (selectedItems.isEmpty) isInSelectionMode = false;
    }
    _view.notifyDataChanged();
  }

  @override
  bool isItemSelected(int index) => selectedItems.contains(index);

  @override
  bool get isEmpty => _filteredList.isEmpty;
}
