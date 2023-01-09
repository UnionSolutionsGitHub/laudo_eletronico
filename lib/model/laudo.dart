import 'package:laudo_eletronico/model/agendamento.dart';
import 'package:laudo_eletronico/model/answer.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/additional_photo.dart';
import 'package:laudo_eletronico/model/note.dart';

import './user.dart';

class Laudo {
  int id, foreignId;
  String carPlate, mileage, vehicleLogoName, vehicleBrand, vehicleModel, chassi, engineNumber;
  DateTime date;
  bool isPhotoDone, isPaintingDone, isStructureDone, isIdentifyDone, hasPhoto, hasPainting, hasStructure, hasIdentify;
  User user;
  Configuration configuration;
  List<Answer> answers;
  List<AdditionalPhoto> additionalPhotos;
  Agendamento agendamento;
  List<Note> notes;

  Laudo({
    this.id,
    this.carPlate,
    this.mileage,
    this.vehicleLogoName,
    this.vehicleBrand,
    this.vehicleModel,
    this.date,
    this.isPhotoDone,
    this.isPaintingDone,
    this.isStructureDone,
    this.isIdentifyDone,
    this.hasPhoto,
    this.hasPainting,
    this.hasStructure,
    this.hasIdentify,
    this.user,
    this.configuration,
    this.answers,
    this.additionalPhotos,
    this.chassi,
    this.engineNumber,
    this.foreignId,
    this.agendamento,
    this.notes,
  });
}
