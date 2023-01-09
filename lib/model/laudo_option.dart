class LaudoOption {
  int id;
  String laudoType, type, subtype, value;

  LaudoOption({
    this.id,
    this.laudoType,
    this.type,
    this.subtype,
    this.value,
  });
}

class LaudoOptionTypes {
  static const OK = "OK";
  static const Alert = "ALERT";
  static const Risk = "RISK";
  static const NA = "Não Aplicável";
}
