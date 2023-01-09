import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/model/vehicle_information.dart';

class VehicleInformationDTO extends DataTransferObject<VehicleInformations> {
  @override
  Future<VehicleInformations> fromJson(dynamic json) async {
    return VehicleInformations(
      tipoVeiculo: json["tipoVeiculo"],
      marca: json["marca"],
      anoFababricacao: json["anoFab"],
      ufPlaca: json["ufPlaca"],
      combustivel: json["combustivel"],
      numeroMotor: json["nrMotor"],
      remarcacaoChassi: json["remarcacaoChassi"],
      anoModelo: json["anoMod"],
      cor: json["cor"],
      chassi: json["chassi"],
      modelo: json["modelo"],
      placa: json["placa"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }
}
