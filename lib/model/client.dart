import 'package:laudo_eletronico/model/user.dart';

import './configuration.dart';

class Client {
  int id;
  String name;
  bool isLoose;
  List<Configuration> configurations;

  User user;

  Client({
    this.id,
    this.name,
    this.isLoose,
    this.configurations,
    this.user,
  });
}