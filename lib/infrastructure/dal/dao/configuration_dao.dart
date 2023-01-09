import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/client.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/user.dart';

class ConfigurationDAO extends DataAccessObject<Configuration> {
  @override
  String get tableName => "CONFIGURATION";
  @override
  List<Column> get columns => [
    columnId,
    columnClientId,
    //columnUserId,
    columnName,
    columnDisabled,
    columnAdditionalPhoto,
  ];

  @override
  Configuration fromMap(Map<String, dynamic> map) {
    return Configuration(
      id: map[columnId.name],
      name: map[columnName.name],
      isDisabled: super.valueOf(map, columnDisabled),
      client: map[columnClientId.name] != null ? Client(id: map[columnClientId.name]) : null,
      additionalPhoto: super.valueOf(map, columnAdditionalPhoto),
      //user: User(id: map[columnUserId.name]),
    );
  }

  @override
  Map<String, dynamic> toMap(Configuration configuration) {
    return {
      columnId.name: configuration.id,
      columnClientId.name: configuration?.client?.id,
      //columnUserId.name: configuration?.user?.id,
      columnName.name: configuration.name,
      columnDisabled.name: configuration.isDisabled,
      columnAdditionalPhoto.name:configuration.additionalPhoto,
    };
  }

  final columnId = const Column(name: "ID", type: ColumnTypes.Int, isPrimaryKey: true, canBeNull: false);
  final columnClientId = const Column(name: "CLIENT_ID", type: ColumnTypes.Int);
  final columnUserId = const Column(name: "USER_ID", type: ColumnTypes.Int);
  final columnName = const Column(name: "NAME", type: ColumnTypes.Text);
  final columnDisabled = const Column(name: "DISABLED", type: ColumnTypes.Boolean);
  final columnAdditionalPhoto = const Column(name: "ADDITIONAL_PHOTO", type: ColumnTypes.Boolean);
}
