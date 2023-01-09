import 'package:laudo_eletronico/infrastructure/services/service_base.dart';

class LoginDTO extends DataTransferObject {
  String login, senha, token;

  LoginDTO({this.login, this.senha, this.token});

  @override
  Future fromJson(dynamic json) {
    return null;
  }

  @override
  Map<String, dynamic> toJson() => {
        'login': login,
        'senha': senha,
        'token': token,
      };
}
