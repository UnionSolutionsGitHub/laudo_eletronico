import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bll/agendamento_bo.dart';
import 'package:laudo_eletronico/common/widgets/configuration_menu_button.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/client_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_option_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/user_configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/user_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/main.dart';
import 'package:laudo_eletronico/model/client.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/model/user_configuration.dart';

import 'package:laudo_eletronico/presentation/nova_vistoria/nova_vistoria_view.dart';
import 'package:laudo_eletronico/presentation/vistorias_pendentes/vistorias_pendentes_view.dart';

import './login_contract.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:collection/collection.dart' as collection;

class LoginPresenter implements LoginPresenterContract {
  LoginViewContract _view;
  UnionSolutionsService _service;

  LoginPresenter(this._view, this._service) {
    _edtxControllerUsername = TextEditingController();
    _edtxControllerPassword = TextEditingController();

    _edtxFocusNodeUser = FocusNode();
    _edtxFocusNodePassword = FocusNode();
  }

  TextEditingController _edtxControllerUsername;
  TextEditingController _edtxControllerPassword;

  FocusNode _edtxFocusNodeUser;
  FocusNode _edtxFocusNodePassword;

  @override
  TextEditingController get edtxControllerUsername => _edtxControllerUsername;

  @override
  TextEditingController get edtxControllerPassword => _edtxControllerPassword;

  @override
  FocusNode get edtxFocusNodeUser => _edtxFocusNodeUser;

  @override
  FocusNode get edtxFocusNodePassword => _edtxFocusNodePassword;

  @override
  void doLogin() async {
    _view.showProgressIndeterminate();
    _doLogin();
  }

  _doLogin() async {
    if (this._edtxControllerUsername?.text?.isEmpty == true) {
      _view.hideProgressIndeterminate();
      this._view.showErrorMessage("login_erro_message_empty_username");
      return;
    }

    if (this._edtxControllerPassword?.text?.isEmpty == true) {
      _view.hideProgressIndeterminate();
      this._view.showErrorMessage("login_erro_message_empty_password");
      return;
    }

    String token = await this._service.doLogin(
          this._edtxControllerUsername?.text ?? "",
          this._edtxControllerPassword?.text ?? "",
        );

    if (token?.isEmpty == true) {
      _view.hideProgressIndeterminate();
      this._view.showErrorMessage("login_erro_message_invalid_login");
      return;
    }

    LocalResources localResources = await LocalResources().instance();
    localResources.token = token;

    final userDAO = UserDAO();
    final user = User.fromToken(token);

    LaudoDAO laudoDao = LaudoDAO();

    await _checkUpdate(user, userDAO, laudoDao);
    await AgendamentoBO().checkAgendamentos(user);
    //await _checkAgendamentos(user);

    _view.hideProgressIndeterminate();

    if (await laudoDao.arePending(user)) {
      _view.navigatorPushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => VistoriasPendentesView(
            configMenu: ConfigurationMenuButton(),
          ),
        ),
      );
    } else {
      _view.navigatorPushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => NovaVistoriaView(
            configMenu: ConfigurationMenuButton(),
          ),
        ),
      );
    }

    if (!(localResources.tutorialCompleted ?? false)) {
      _view.navigatorPushNamed(Routes.TUTORIAL);
    }
  }

  Future _checkUpdate(User user, UserDAO userDAO, LaudoDAO laudoDao) async {
    final configurationDao = ConfigurationDAO();
    final userConfigurationDao = UserConfigurationDAO();

    final userConfigurations = await userConfigurationDao.get(args: {
      userConfigurationDao.columnUserId: user.id,
    }) as List<UserConfiguration>;

    final checkForUpdateDto = await _service.checkForUpdate(userConfigurations.map<int>((item) => item.configurationId).toList());

    final existentConfigurationIds = <int>[];

    for (var id in checkForUpdateDto.newConfigs) {
      if (await configurationDao.exists(args: { configurationDao.columnId: id })) {
        await userConfigurationDao.insert(UserConfiguration(
            userId: user.id,
            configurationId: id,
          ),
        );

        existentConfigurationIds.add(id);
      }
    }

    checkForUpdateDto.newConfigs.removeWhere((id) => existentConfigurationIds.contains(id));

    final newConfigurations = await _service.retrieveConfigurations(ids: checkForUpdateDto.newConfigs);

    if (newConfigurations.length > 0) {
      user.clients = newConfigurations;
      await userDAO.insertWithConfigurations(user);

      final disabledConfigurations = await configurationDao.get(args: {configurationDao.columnId: checkForUpdateDto.disableds});

      for (Configuration configuration in disabledConfigurations) {
        if (await laudoDao.exists(args: {laudoDao.columnConfigurationId: configuration.id})) {
          configuration.isDisabled = true;
          configurationDao.update(configuration);
          continue;
        }

        configurationDao.delete({configurationDao.columnId: configuration.id});
        userConfigurationDao.delete({userConfigurationDao.columnConfigurationId: configuration.id});
      }
    }

    if (existentConfigurationIds.length > 0) {
      await userDAO.insert(user);
    }

    /* if (existentConfigurationIds.length > 0) {
      final clientDao = ClientDAO();

      final clientIds = (await configurationDao.get(args: {configurationDao.columnId: existentConfigurationIds}) as List<Configuration>).map<int>((x) => x.client.id).toList();

      final filteredClientIds = collection.groupBy(clientIds, (x) => x);

      final clientsToCreate = await clientDao.get(args: {clientDao.columnId: filteredClientIds}) as List<Client>;

      for (var client in clientsToCreate) {
        client.user = user;
        await clientDao.insert(client);
      }
    } */

    final laudoOptions = await _service.getOptions();
    final laudoOptionDao = LaudoOptionDAO();
    laudoOptionDao.clear();
    laudoOptionDao.insertMany(laudoOptions);
  }
}
