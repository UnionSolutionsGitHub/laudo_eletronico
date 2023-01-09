import 'dart:io';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/check_for_update_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/configuration_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/laudo_agendado_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/laudo_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/laudo_option_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/login_dto.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/dto/vehicle_information_dto.dart';
import 'package:laudo_eletronico/model/client.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/laudo_option.dart';
import 'package:laudo_eletronico/model/vehicle_information.dart';

class UnionSolutionsService {
  //Produção
  //final ServiceBase service = ServiceBase(urlBase: "http://sistema.unionsolutions.com.br/ws");
  
  //Homologação
  //final ServiceBase service = ServiceBase(urlBase: "http://homologacao.unionsolutions.com.br/ws");
  final ServiceBase service = ServiceBase(urlBase: "http://homologacao.ws.unionsolutions.com.br");
  
  //final ServiceBase service = ServiceBase(urlBase: "http://172.25.0.97:8080/UnionSolutionsWebservice");

  Future<String> doLogin(String username, String password) async {
    try {
      final serviceName = "/mobile/login";
      final loginDTO = LoginDTO(
        login: username,
        senha: password,
        token: await FirebaseMessaging().getToken(),
      );

      final token = await service.post(
        serviceName: serviceName,
        object: loginDTO,
      );

      return token;
    } catch (e) {
      return "";
    }
  }

  Future<VehicleInformations> getVehicleInformation(String carPlate) async {
    try {
      final serviceName = "/mobile/preencheVeiculo/$carPlate";
      final vehicleInformations = await service.get(
        serviceName: serviceName,
        object: VehicleInformationDTO(),
      );

      return vehicleInformations as VehicleInformations;
    } catch (e) {
      throw Exception();
    }
  }

  Future<CheckForUpdateDTO> checkForUpdate(List<int> ids) async {
    try {
      final serviceName = "/mobile/buscaConfigsAtualizadas";

      return await service.postAsJson(
        serviceName: serviceName,
        object: CheckForUpdateDTO(ids),
      );
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<Client>> retrieveConfigurations({List<int> ids}) async {
    try {
      final serviceName = "/mobile/getListaClienteLaudo";

      return await service.postAsJson(
        serviceName: serviceName,
        object: ConfigurationDTO(ids ?? List<int>()),
      );
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<LaudoOption>> getOptions() async {
    final serviceName = "/mobile/getLaudoOptions";
    return await service.get(
      serviceName: serviceName,
      object: LaudoOptionDTO(),
    );
  }

  Future<String> uploadImage(String path) async {
    try {
      final serviceName = "/laudo/salvarImagemLaudoEletronico";

      final photo = File.fromUri(Uri(path: path));

      if (!(await photo.exists())) {
        return "";
      }

      return (await service.postAsFormData(
        serviceName: serviceName,
        file: photo,
      ))["url"];
    } on TimeoutException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future sendLaudo(Laudo laudo) async {
    try {
      final serviceName = "/mobile/salvarLaudoEletronico";

      return await service.postAsJson(
        serviceName: serviceName,
        object: LaudoDTO(laudo: laudo),
      );
    } catch (e) {
      throw e;
    }
  }

  Future<CheckForUpdateDTO> checkForAgendamentos(List<int> ids) async {
    try {
      final serviceName = "/mobile/buscaLaudosAgendados";

      return await service.postAsJson(
        serviceName: serviceName,
        object: CheckForUpdateDTO(ids ?? List<int>()),
      );
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<Laudo>> retrieveLaudosAgendados({List<int> ids}) async {
    try {
      final serviceName = "/mobile/getLaudosAgendados";

      return await service.postAsJson(
        serviceName: serviceName,
        object: LaudoAgendadoDTO(ids ?? List<int>()),
      );
    } catch (e) {
      throw Exception();
    }
  }
}
