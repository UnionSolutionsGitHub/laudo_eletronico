import 'dart:io';

import 'package:laudo_eletronico/infrastructure/dal/dao/additional_photo_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/user.dart';

class LaudoDAO extends DataAccessObject<Laudo> {
  @override
  String get tableName => "LAUDO";

  @override
  List<Column> get columns => [
        columnId,
        columnUserId,
        columnConfigurationId,
        columnDate,
        columnCarPlate,
        columnMilage,
        columnVehicleLogoName,
        columnVehicleBrand,
        columnVehicleModel,
        columnIsPhotoDone,
        columnIsPaintingDone,
        columnIsStructureDone,
        columnIsIdentifyDone,
        columnHasPhoto,
        columnHasPainting,
        columnHasStructure,
        columnHasIdentify,
        columnChassi,
        columnEngineNumber,
        columnForeignId,
      ];

  @override
  Laudo fromMap(Map<String, dynamic> map) {
    return Laudo(
      id: map[columnId.name],
      carPlate: map[columnCarPlate.name],
      mileage: map[columnMilage.name],
      date: super.valueOf(map, columnDate),
      vehicleBrand: map[columnVehicleBrand.name],
      vehicleLogoName: map[columnVehicleLogoName.name],
      vehicleModel: map[columnVehicleModel.name],
      isPhotoDone: map[columnIsPhotoDone.name] == 1,
      isPaintingDone: map[columnIsPaintingDone.name] == 1,
      isStructureDone: map[columnIsStructureDone.name] == 1,
      isIdentifyDone: map[columnIsIdentifyDone.name] == 1,
      hasPhoto: map[columnHasPhoto.name] == 1,
      hasPainting: map[columnHasPainting.name] == 1,
      hasStructure: map[columnHasStructure.name] == 1,
      hasIdentify: map[columnHasIdentify.name] == 1,
      user: User(id: map[columnUserId.name]),
      configuration: Configuration(id: map[columnConfigurationId.name]),
      chassi: map[columnChassi.name],
      engineNumber: map[columnEngineNumber.name],
      foreignId: map[columnForeignId.name],
    );
  }

  @override
  Map<String, dynamic> toMap(Laudo laudo) {
    return {
      columnId.name: laudo.id,
      columnUserId.name: laudo.user.id,
      columnConfigurationId.name: laudo.configuration.id,
      columnCarPlate.name: laudo.carPlate,
      columnMilage.name: laudo.mileage,
      columnDate.name: laudo.date?.millisecondsSinceEpoch,
      columnVehicleLogoName.name: laudo.vehicleLogoName,
      columnVehicleBrand.name: laudo.vehicleBrand,
      columnVehicleModel.name: laudo.vehicleModel,
      columnIsPhotoDone.name: laudo.isPhotoDone,
      columnIsPaintingDone.name: laudo.isPaintingDone,
      columnIsStructureDone.name: laudo.isStructureDone,
      columnIsIdentifyDone.name: laudo.isIdentifyDone,
      columnHasPhoto.name: laudo.hasPhoto,
      columnHasPainting.name: laudo.hasPainting,
      columnHasStructure.name: laudo.hasStructure,
      columnHasIdentify.name: laudo.hasIdentify,
      columnChassi.name: laudo.chassi,
      columnEngineNumber.name: laudo.engineNumber,
      columnForeignId.name: laudo.foreignId,
    };
  }

  Future<bool> arePending(User user) async {
    return await this.exists(args: {
      columnUserId: user.id,
    });
  }

  Future deleteWithAnswers(Laudo laudo) async {
    final answerDao = AnswerDAO();
    final additionalPhotoDao = AdditionalPhotoDAO();
    final answerAttachmentDao = AnswerAttachmentDAO();

    if (laudo.answers?.isNotEmpty == true) {
      await answerDao.delete({
        answerDao.columnId: laudo.answers.map((answer) => answer.id).toList(),
      });

      await answerAttachmentDao.delete({
        answerAttachmentDao.columnAnswerId:
            laudo.answers.map((answer) => answer.id).toList(),
      });

      for (var photo in laudo.answers
          .where((answer) => answer.attachment != null)
          .map((answer) => answer.attachment)
          .toList()) {
        File file = File.fromUri(Uri(path: photo.path));

        if (!(await file.exists())) {
          continue;
        }

        await file.delete();

        File fileThumbnail = File.fromUri(
            Uri(path: "${photo.path.replaceAll(".png", "")}_thumbnail.png"));

        if (!(await fileThumbnail.exists())) {
          continue;
        }

        await fileThumbnail.delete();
      }
    }

    if (laudo.additionalPhotos?.isNotEmpty == true) {
      await additionalPhotoDao.delete({
        additionalPhotoDao.columnId:
            laudo.additionalPhotos.map((photo) => photo.id).toList(),
      });

      for (var photo in laudo.additionalPhotos) {
        File file = File.fromUri(Uri(path: photo.path));

        if (!(await file.exists())) {
          continue;
        }

        await file.delete();

        File fileThumbnail = File.fromUri(
            Uri(path: "${photo.path.replaceAll(".png", "")}_thumbnail.png"));

        if (!(await fileThumbnail.exists())) {
          continue;
        }

        await fileThumbnail.delete();
      }
    }

    super.delete({
      this.columnId: laudo.id,
    });
  }

  final columnId = const Column(
      name: "ID",
      type: ColumnTypes.Int,
      isPrimaryKey: true,
      isAutoincrement: true);
  final columnForeignId =
      const Column(name: "FOREIGN_ID", type: ColumnTypes.Int);
  final columnUserId = const Column(name: "USER_ID", type: ColumnTypes.Int);
  final columnConfigurationId =
      const Column(name: "CONFIGURATION_ID", type: ColumnTypes.Int);
  final columnCarPlate =
      const Column(name: "CAR_PLATE", type: ColumnTypes.Text);
  final columnChassi = const Column(name: "CHASSI", type: ColumnTypes.Text);
  final columnEngineNumber =
      const Column(name: "ENGINE_NUMBER", type: ColumnTypes.Text);
  final columnMilage = const Column(name: "MILAGE", type: ColumnTypes.Text);
  final columnVehicleLogoName =
      const Column(name: "VEHICLE_LOGO_NAME", type: ColumnTypes.Text);
  final columnVehicleBrand =
      const Column(name: "VEHICLE_BRAND", type: ColumnTypes.Text);
  final columnVehicleModel =
      const Column(name: "VEHICLE_MODEL", type: ColumnTypes.Text);
  final columnDate = const Column(name: "DATE", type: ColumnTypes.Date);
  final columnIsPhotoDone =
      const Column(name: "IS_PHOTO_DONE", type: ColumnTypes.Boolean);
  final columnIsPaintingDone =
      const Column(name: "IS_PAINTING_DONE", type: ColumnTypes.Boolean);
  final columnIsStructureDone =
      const Column(name: "IS_STRUCTURE_DONE", type: ColumnTypes.Boolean);
  final columnIsIdentifyDone =
      const Column(name: "IS_IDENTIFY_DONE", type: ColumnTypes.Boolean);
  final columnHasPhoto =
      const Column(name: "HAS_PHOTO", type: ColumnTypes.Boolean);
  final columnHasPainting =
      const Column(name: "HAS_PAINTING", type: ColumnTypes.Boolean);
  final columnHasStructure =
      const Column(name: "HAS_STRUCTURE", type: ColumnTypes.Boolean);
  final columnHasIdentify =
      const Column(name: "HAS_IDENTIFY", type: ColumnTypes.Boolean);
}
