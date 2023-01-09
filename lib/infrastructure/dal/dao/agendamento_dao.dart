import 'package:laudo_eletronico/infrastructure/dal/database_helper.dart';
import 'package:laudo_eletronico/model/agendamento.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/user.dart';

class AgendamentoDAO extends DataAccessObject<Agendamento> {
  @override
  String get tableName => "AGENDAMENTO";
  @override
  List<Column> get columns => [
        //columnId,
        columnLaudoId,
        columnDate,
        columnRua,
        columnNumero,
        columnBairro,
        columnCidade,
        columnEstado,
        columnCep,
        columnPeriodo,
        columnUserId,
      ];

  @override
  Agendamento fromMap(Map<String, dynamic> map) {
    return Agendamento(
      rua: map[columnRua.name],
      numero: map[columnNumero.name],
      bairro: map[columnBairro.name],
      cidade: map[columnCidade.name],
      estado: map[columnEstado.name],
      cep: map[columnCep.name],
      date: this.valueOf(map, columnDate),
      periodo: map[columnPeriodo.name],
      laudo: Laudo(foreignId: map[columnLaudoId.name]),
      user: User(id: map[columnUserId.name]),
    );
  }

  @override
  Map<String, dynamic> toMap(Agendamento agendamento) {
    return {
      columnLaudoId.name: agendamento.laudo.foreignId,
      columnDate.name: agendamento.date.millisecondsSinceEpoch,
      columnRua.name: agendamento.rua,
      columnNumero.name: agendamento.numero,
      columnBairro.name: agendamento.bairro,
      columnCidade.name: agendamento.cidade,
      columnEstado.name: agendamento.estado,
      columnCep.name: agendamento.cep,
      columnPeriodo.name: agendamento.periodo,
      columnUserId.name: agendamento.user.id,
    };
  }

  //final columnId = const Column(name: "ID", type: ColumnTypes.Int, isPrimaryKey: true, canBeNull: false);
  final columnLaudoId = const Column(name: "LAUDO_ID", type: ColumnTypes.Int, canBeNull: false);
  final columnUserId = const Column(name: "USER_ID", type: ColumnTypes.Int, canBeNull: false);
  final columnDate = const Column(name: "DATE", type: ColumnTypes.Date);
  final columnRua = const Column(name: "RUA", type: ColumnTypes.Text);
  final columnNumero = const Column(name: "NUMERO", type: ColumnTypes.Text);
  final columnBairro = const Column(name: "BAIRRO", type: ColumnTypes.Text);
  final columnCidade = const Column(name: "CIDADE", type: ColumnTypes.Text);
  final columnEstado = const Column(name: "ESTADO", type: ColumnTypes.Text);
  final columnCep = const Column(name: "CEP", type: ColumnTypes.Text);
  final columnPeriodo = const Column(name: "PERIODO", type: ColumnTypes.Text);
}
