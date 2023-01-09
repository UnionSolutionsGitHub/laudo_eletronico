import 'package:connectivity/connectivity.dart';
import 'package:laudo_eletronico/bll/agendamento_bo.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/user_configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/user_dao.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';

import 'package:laudo_eletronico/main.dart';
import 'package:laudo_eletronico/infrastructure/dal/database_context.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/model/user_configuration.dart';

import './splash_screen_contract.dart';

class SplashScreenPresenter implements SplashScreenPresenterContract {
  SplashScreenViewContract _view;
  UnionSolutionsService _service;

  SplashScreenPresenter(this._view, this._service) {
    DatabaseContext.setOnDatabaseContextinitializedListener(() async {
      _checkInfos();
    });
  }

  void _checkInfos() async {
    LocalResources localResources = await LocalResources().instance();
    String route;
    if (localResources?.token?.isNotEmpty != true) {
      route = Routes.LOGIN;
    } else {
      final user = User.fromToken(localResources?.token);

      await _checkUpdate(user);

      await AgendamentoBO().checkAgendamentos(user);

      if (await LaudoDAO().arePending(user)) {
        route = Routes.VISTORIAS_PENDENTES;
      } else {
        route = Routes.NOVA_VISTORIA;
      }
    }
    _view.navigatorPushReplacementNamed(route);
  }

  Future _checkUpdate(User user) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return;
      }

      final configurationDao = ConfigurationDAO();

      /* final configurations = await configurationDao.get(args: {
        configurationDao.columnDisabled: false,
        configurationDao.columnUserId: user.id,
      }) as List<Configuration>;

      final configurationsIds = configurations
          .map<int>((Configuration configuration) => configuration.id)
          .toList(); */

          final userConfigurationDao = UserConfigurationDAO();

    final userConfigurations = await userConfigurationDao.get(args: {
      userConfigurationDao.columnUserId: user.id,
    }) as List<UserConfiguration>;

      final checkForUpdateDto = await _service.checkForUpdate(userConfigurations.map<int>((item) => item.configurationId).toList());

      if (checkForUpdateDto.newConfigs.length > 0) {
        final newConfigurations = await _service.retrieveConfigurations(
            ids: checkForUpdateDto.newConfigs);

        final userDAO = UserDAO();
        user.clients = newConfigurations;
        await userDAO.insertWithConfigurations(user);
      }

      final disabledConfigurations = await configurationDao.get(args: {configurationDao.columnId: checkForUpdateDto.disableds});

      final laudoDao = LaudoDAO();

      for (Configuration configuration in disabledConfigurations) {
        if (await laudoDao
            .exists(args: {laudoDao.columnConfigurationId: configuration.id})) {
          configuration.isDisabled = true;
          configurationDao.update(configuration);
          continue;
        }

        configurationDao.delete({configurationDao.columnId: configuration.id});
        userConfigurationDao.delete({userConfigurationDao.columnConfigurationId: configuration.id});
      }
    } catch (e) {
      print(e.message);
    }
  }
}
