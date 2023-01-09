import 'dart:convert';

import 'package:laudo_eletronico/model/client.dart';

class User {
  int id;
  String name;

  List<Client> _clients;

  User({
    this.id,
    this.name,
  });

  User.fromToken(String token) {
    final base64UserInfos = token?.split('.')[0];
    final bytesUserInfos = Base64Codec().decode(base64UserInfos);
    final jsonString = String.fromCharCodes(bytesUserInfos);
    final map = json.decode(jsonString);

    this.id = map["id"];
    this.name = map["nome"];
  }

  List<Client> get clients => _clients;
  set clients(List<Client> clients) {
    _clients = clients;
    _clients.forEach((client) => client.user = this);
  }
}