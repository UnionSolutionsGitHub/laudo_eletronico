import 'package:laudo_eletronico/infrastructure/services/service_base.dart';
import 'package:laudo_eletronico/model/client.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/input_type.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';

class ConfigurationDTO extends DataTransferObject {
  List<int> ids;

  ConfigurationDTO(this.ids);

  @override
  Map<String, dynamic> toJson() {
    return {
      "ids": ids,
    };
  }

  @override
  Future<List<Client>> fromJson(dynamic json) async {
    if (!(json is Map)) {
      return List();
    }

    final clients = json["clientes"]
        .toList()
        .map<Client>(
          (map) => Client(
                id: map["id"],
                name: map["nome"].trim(),
                isLoose: map["isAvulso"],
                configurations: map["configs"]
                    .toList()
                    .map<Configuration>(
                      (configs) => Configuration(
                            id: configs["id"],
                            name: configs["nome"].trim(),
                            additionalPhoto: configs["fotosAdicionais"],
                            items: configs["itens"]
                                .toList()
                                .map<ItemConfiguration>(
                                  (item) => ItemConfiguration(
                                        key: item["id"],
                                        descption: item["descricao"],
                                        isMandatory: item["obrigatorio"],
                                        isNotApplicable: item["temNaoAplicavel"],
                                        type: item["tipo"],
                                        subtype: item["subtipo"],
									  	                  inputType: inputTypeFor(item["tipoEntrada"]),
                                        order: item["ordem"],
                                      ),
                                )
                                .toList(),
                          ),
                    )
                    .toList(),
              ),
        )
        .toList();

    clients.forEach(
      (Client client) => client.configurations.forEach(
            (Configuration configuration) {
              configuration.client = client;
              configuration.items.forEach(
                (ItemConfiguration item) => item.configuration = configuration,
              );
            },
          ),
    );

    return clients;
  }
}
