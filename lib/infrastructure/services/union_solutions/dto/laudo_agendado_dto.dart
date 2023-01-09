import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/model/agendamento.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/laudo.dart';

class LaudoAgendadoDTO implements DataTransferObject {
  List<int> ids;

  LaudoAgendadoDTO(this.ids);

  @override
  Map<String, dynamic> toJson() {
    return {
      "ids": ids,
    };
  }

  @override
  Future<List<Laudo>> fromJson(json) async {
    return json.map<Laudo>((map) {
      final laudo = Laudo(
          foreignId: map["id"],
          configuration: Configuration(
            id: map["idconfig"],
          ),
          vehicleBrand: map["marca"],
          vehicleModel: map["modelo"],
          chassi: map["chassi"],
          carPlate: map["placa"]);

      laudo.agendamento = Agendamento(
          rua: map["rua"],
          numero: map["numero"].toString(),
          bairro: map["bairro"],
          cidade: map["cidade"],
          estado: map["estado"],
          cep: map["cep"],
          date: DateTime.fromMillisecondsSinceEpoch(map["dataagendamento"]),
          periodo: map["periodoagendamento"],
          laudo: laudo);

      return laudo;
    }).toList();
  }
}
