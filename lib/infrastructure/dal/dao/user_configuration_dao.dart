import 'package:laudo_eletronico/model/user_configuration.dart';

import '../database_helper.dart';

class UserConfigurationDAO extends DataAccessObject<UserConfiguration> {
  @override
  String get tableName => "USER_CONFIGURATION";
  @override
  List<Column> get columns => [
        columnUserId,
        columnConfigurationId,
      ];

  @override
  UserConfiguration fromMap(Map<String, dynamic> map) {
    return UserConfiguration(
      userId: map[columnUserId.name],
      configurationId: map[columnConfigurationId.name],
    );
  }

  @override
  Map<String, dynamic> toMap(UserConfiguration userConfiguration) {
    return {
      columnUserId.name: userConfiguration.userId,
      columnConfigurationId.name: userConfiguration.configurationId,
    };
  }

  final columnUserId = const Column(name: "USER_ID", type: ColumnTypes.Int);
  final columnConfigurationId = const Column(name: "CONFIGURATION_ID", type: ColumnTypes.Int);
}
