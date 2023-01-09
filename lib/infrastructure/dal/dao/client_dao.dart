import 'package:laudo_eletronico/infrastructure/dal/dao/configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/client.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/model/user_configuration.dart';

import 'user_configuration_dao.dart';

class ClientDAO extends DataAccessObject<Client> {
  @override
  String get tableName => "CLIENT";

  @override
  List<Column> get columns => [
        this.columnId,
        this.columnUserId,
        this.columnName,
        this.columnIsLoose,
      ];

  @override
  Client fromMap(Map<String, dynamic> map) {
    return Client(
      id: map[columnId.name],
      name: map[columnName.name],
      isLoose: map[columnIsLoose.name] == 1,
    );
  }

  @override
  Map<String, dynamic> toMap(Client client) {
    return {
      columnId.name: client.id,
      columnUserId.name: client.user.id,
      columnName.name: client.name,
      columnIsLoose.name: client.isLoose,
    };
  }

  Future<List<Client>> getWithConfiguration(User user) async {
    final configurationDao = ConfigurationDAO();
    final userConfigurationDao = UserConfigurationDAO();

    final userConfigurations = await userConfigurationDao.get(args: {
      userConfigurationDao.columnUserId: user.id,
    }) as List<UserConfiguration>;

    final configurations = await configurationDao.get(args: {
          configurationDao.columnDisabled: false,
          configurationDao.columnId: userConfigurations.map<int>((item) => item.configurationId).toList(),
        }) as List<Configuration>;

    final clientIds = configurations.map<int>((configuration) => configuration.client.id).toList();

    final clients = await this.get(args: {columnId: clientIds}) as List<Client>;

    clients.forEach((client) { 
      client.configurations = configurations.where((configuration) => configuration.client.id == client.id).toList();
      client.configurations.forEach((configuration) => configuration.client = client);
    });

    return clients;

    /* final configurationDao = ConfigurationDAO();

    final clients = await this.get(args: {columnUserId: user.id}) as List<Client>;

    if (clients.where((c) => c.isLoose).length > 1) {
      final loose = clients.firstWhere((c) => c.isLoose);
      clients.removeWhere((c) => c.isLoose);
      clients.add(loose);
    }

    final userConfigurationDao = UserConfigurationDAO();

    final userConfigurations = await userConfigurationDao.get(args: {
      userConfigurationDao.columnUserId: user.id,
    }) as List<UserConfiguration>;

    for (var client in clients) {
      List<Configuration> configurations;

      try {
        configurations = await configurationDao.get(args: {
          configurationDao.columnDisabled: false,
          configurationDao.columnId: userConfigurations.map<int>((item) => item.configurationId).toList(),
        });
      } catch (e) {
        print(e.message);
      }

      configurations.removeWhere((configuration) => configuration.isDisabled);
      configurations.forEach((configuration) => configuration.client = client);
      client.configurations = configurations;
    }

    return clients; */
  }

  final columnId = const Column(name: "ID", type: ColumnTypes.Int, isPrimaryKey: true, canBeNull: false);
  final columnUserId = const Column(name: "USER_ID", type: ColumnTypes.Int, canBeNull: false);
  final columnName = const Column(name: "NAME", type: ColumnTypes.Text);
  final columnIsLoose = const Column(name: "IS_LOOSE", type: ColumnTypes.Boolean);
}
