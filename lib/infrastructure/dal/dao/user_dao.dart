import 'package:laudo_eletronico/infrastructure/dal/dao/client_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/configuration_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/item_configuration_dao.dart';
import 'package:laudo_eletronico/model/client.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:laudo_eletronico/model/user_configuration.dart';

import '../database_helper.dart';
import 'user_configuration_dao.dart';

class UserDAO extends DataAccessObject<User> {
  @override
  String get tableName => "USER";

  @override
  List<Column> get columns => [
        columnId,
        columnName,
      ];

  @override
  Map<String, dynamic> toMap(User user) {
    return <String, dynamic>{
      columnId.name: user.id,
      columnName.name: user.name,
    };
  }

  @override
  User fromMap(Map<String, dynamic> map) {
    return User(
      id: map[columnId.name],
      name: map[columnName.name],
    );
  }

  Future insertWithoutConfigurations(User user) async {
    final clientDAO = ClientDAO();

    try {
      await super.insert(user);

      try {
        final looses = await clientDAO.get(args: {
          clientDAO.columnUserId: user.id,
          clientDAO.columnIsLoose: true,
        }) as List<Client>;

        var loose = looses.length > 0 ? looses[0] : null;

        if (loose == null) {
          loose = user.clients.firstWhere((c) => c.isLoose);
          loose.id = int.parse("99999${user.id}");
        }

        user.clients.where((c) => c.isLoose).forEach((c) => c.id = loose.id);
      } catch (e) {
        print(e.message);
      }

      await clientDAO.insertMany(user.clients);
    }
    catch (e) {
      print(e.message);
    }
  }

  Future insertWithConfigurations(User user) async {
    final clientDAO = ClientDAO();
    final configurationDAO = ConfigurationDAO();
    final itemConfigurationDAO = ItemConfigurationDAO();
    final userConfigurationDAO = UserConfigurationDAO();

    try {
      await super.insert(user);

      try {
        final looses = await clientDAO.get(args: {
          clientDAO.columnUserId: user.id,
          clientDAO.columnIsLoose: true,
        }) as List<Client>;

        var loose = looses.length > 0 ? looses[0] : null;

        if (loose == null) {
          loose = user.clients.firstWhere((c) => c.isLoose);
          loose.id = int.parse("99999${user.id}");
        }

        user.clients.where((c) => c.isLoose).forEach((c) => c.id = loose.id);
      } catch (e) {
        print(e.message);
      }

      await clientDAO.insertMany(user.clients);

      final configurations = List<Configuration>();
      final userConfigurations = List<UserConfiguration>();

      user.clients.forEach((client) {
        client.configurations.forEach((configuration) {
          //configuration.user = user;
          configuration.client = client;

          userConfigurations.add(UserConfiguration(
            userId: user.id,
            configurationId: configuration.id,
          ));
        });

        configurations.addAll(client.configurations);
      });

      await configurationDAO.insertMany(configurations);
      await userConfigurationDAO.insertMany(userConfigurations);

      user.clients.forEach(
        (client) => client.configurations.forEach(
          (configuration) async {
            final exists = await itemConfigurationDAO.exists(args: {
              itemConfigurationDAO.columnConfigurationId: configuration.id,
            });

            if (exists) {
              await itemConfigurationDAO.delete({
                itemConfigurationDAO.columnConfigurationId: configuration.id,
              });
            }

            itemConfigurationDAO.insertMany(configuration.items);
          },
        ),
      );
    } catch (e) {
      print(e.message);
    }
  }

  final columnId = const Column(
      name: "ID", type: ColumnTypes.Int, isPrimaryKey: true, canBeNull: false);
  final columnName = const Column(name: "NAME", type: ColumnTypes.Text);
}
