import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/user.dart';

class Agendamento {
  String rua, numero, bairro, cidade, estado, cep, periodo;
  DateTime date;
  User user;
  Laudo laudo;

  Agendamento({
    this.rua,
    this.numero,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.date,
    this.periodo,
    this.user,
    this.laudo,
  });

  String get address {
    if (this.rua?.isNotEmpty != true && this.bairro?.isNotEmpty != true && this.cidade?.isNotEmpty != true) {
      return "";
    }

    final address = List<String>();

    if (this.rua?.isNotEmpty == true) {
      address.add(this.rua);
    }

    if (this.numero?.isNotEmpty == true) {
      address.add(this.numero);
    }

    if (this.bairro?.isNotEmpty == true) {
      address.add(this.bairro);
    }

    if (this.cidade?.isNotEmpty == true) {
      address.add(this.cidade);
    }

    if (this.estado?.isNotEmpty == true) {
      address.add(this.estado);
    }

    return address.join(", ");
  }
}
