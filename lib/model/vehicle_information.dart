class VehicleInformations {
  var tipoVeiculo,
      marca,
      anoFababricacao,
      ufPlaca,
      combustivel,
      numeroMotor,
      remarcacaoChassi,
      anoModelo,
      cor,
      chassi,
      modelo,
      placa;

  VehicleInformations({
    this.tipoVeiculo,
    this.marca,
    this.anoFababricacao,
    this.ufPlaca,
    this.combustivel,
    this.numeroMotor,
    this.remarcacaoChassi,
    this.anoModelo,
    this.cor,
    this.chassi,
    this.modelo,
    this.placa,
  });

  String get modelLogoName => this.marca?.toLowerCase();
}