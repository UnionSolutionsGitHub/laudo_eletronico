import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/laudo.dart';

class AdditionalPhotoDAO extends DataAccessObject<AdditionalPhoto> {
  @override
  String get tableName => "ADDITIONAL_PHOTO";
  @override
  List<Column> get columns => [
        columnId,
        columnLaudoId,
        columnPath,
        columnURL,
      ];

  @override
  AdditionalPhoto fromMap(Map<String, dynamic> map) {
    return AdditionalPhoto(
      id: map[columnId.name],
      laudo: Laudo(id: map[columnLaudoId.name]),
      path: map[columnPath.name],
      url: map[columnURL.name],
    );
  }

  @override
  Map<String, dynamic> toMap(AdditionalPhoto additionalPhoto) {
    return {
      columnId.name: additionalPhoto.id,
      columnLaudoId.name: additionalPhoto.laudo.id,
      columnPath.name: additionalPhoto.path,
      columnURL.name: additionalPhoto.url,
    };
  }

  final columnId = const Column(
    name: "ID",
    type: ColumnTypes.Int,
    isPrimaryKey: true,
    canBeNull: false,
  );
  final columnLaudoId = const Column(
    name: "LAUDO_ID",
    type: ColumnTypes.Int,
    canBeNull: false,
  );
  final columnPath = const Column(name: "PATH", type: ColumnTypes.Text);
  final columnURL = const Column(name: "URL", type: ColumnTypes.Text);
}