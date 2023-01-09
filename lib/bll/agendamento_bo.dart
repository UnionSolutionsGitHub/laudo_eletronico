import 'package:connectivity/connectivity.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/agendamento_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/item_configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/agendamento.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/model/item_configuration_type.dart';
import 'package:laudo_eletronico/model/user.dart';

class AgendamentoBO {
  static List<Function> _listener;

  AgendamentoBO() {
    if (_listener == null) {
      _listener = List<Function>();
    }
  }

  addListener(Function f) {
    _listener.add(f);
  }

  removeListener(Function f) {
    _listener.remove(f);
  }

  Future checkAgendamentos(User user) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final _service = UnionSolutionsService();

      if (connectivityResult == ConnectivityResult.none) {
        return;
      }

      final agendamentoDao = AgendamentoDAO();

      final agendamentos = await agendamentoDao.get(args: {
        agendamentoDao.columnUserId: user.id,
      }) as List<Agendamento>;

      final laudosIds = agendamentos
          .map<int>((Agendamento agendamento) => agendamento.laudo.foreignId)
          .toList();

      final checkForUpdateDto = await _service.checkForAgendamentos(laudosIds);

      final laudoDao = LaudoDAO();

      if (checkForUpdateDto.newConfigs.length > 0) {
        final itemConfigurationDao = ItemConfigurationDAO();
        final newAgendados = await _service.retrieveLaudosAgendados(
            ids: checkForUpdateDto.newConfigs);

        for (var agendamento in newAgendados) {
          final configurationItems = await itemConfigurationDao.get(args: {
            itemConfigurationDao.columnConfigurationId:
                agendamento.configuration.id
          }) as List<ItemConfiguration>;

          agendamento.user = user;
          agendamento.hasPhoto = configurationItems.any((item) => item.type == ItemConfigurationType.FOTO);
          agendamento.hasPainting = configurationItems.any((item) => item.type == ItemConfigurationType.PINTURA);
          agendamento.hasStructure = configurationItems.any((item) => item.type == ItemConfigurationType.ESTRUTURA);
          agendamento.hasIdentify = configurationItems.any((item) => item.type == ItemConfigurationType.IDENTIFICACAO);

          agendamento.isPaintingDone = !agendamento.hasPainting;
          agendamento.isStructureDone = !agendamento.hasStructure;
          agendamento.isIdentifyDone = !agendamento.hasIdentify;
        }

        await laudoDao.insertMany(newAgendados);
        await agendamentoDao.insertMany(newAgendados.map<Agendamento>((laudo) {
          laudo.agendamento.user = user;
          return laudo.agendamento;
        }).toList());
      }

      final disabledAgendamentos = await agendamentoDao.get(
        args: {agendamentoDao.columnLaudoId: checkForUpdateDto.disableds},
      );

      for (Agendamento agendamento in disabledAgendamentos) {
        laudoDao.delete(
          {
            laudoDao.columnForeignId: agendamento.laudo.foreignId,
          },
        );
        agendamentoDao.delete(
          {
            agendamentoDao.columnLaudoId: agendamento.laudo.foreignId,
          },
        );
      }
    } catch (e) {
      print(e.message);
    } finally {
      _notifyAll();
    }
  }

  _notifyAll() {
    for (var f in _listener) {
      f();
    }
  }
}
