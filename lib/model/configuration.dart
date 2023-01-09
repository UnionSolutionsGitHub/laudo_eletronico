import 'package:laudo_eletronico/model/client.dart';
import 'package:laudo_eletronico/model/user.dart';

import './item_configuration.dart';

class Configuration {
  int id;
  String name;
  bool isDisabled, additionalPhoto;
  List<ItemConfiguration> items;

  Client client;
  User user;

  Configuration({
    this.id,
    this.name,
    this.isDisabled,
    this.additionalPhoto,
    this.items,
    this.client,
    this.user,
  });
}
