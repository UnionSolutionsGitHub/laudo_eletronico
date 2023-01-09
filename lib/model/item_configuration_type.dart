abstract class ItemConfigurationType {
  static const String FOTO = "FOTO";
  static const String PINTURA = "PINTURA";
  static const String ESTRUTURA = "ESTRUTURA";
  static const String IDENTIFICACAO = "IDENTIFICACAO";
  static const String FOTO_ADICIONAL = "FOTO_ADICIONAL";

  static nextStepBetween(String a, String b) {
    final orderA = _classifyStepOrder(a);
    final orderB = _classifyStepOrder(b);
    return orderA < orderB ? a : b;
  }

  static int _classifyStepOrder(String step) {
    switch (step) {
      case FOTO:
        return 0;
      case PINTURA:
        return 1;
      case ESTRUTURA:
        return 2;
      case IDENTIFICACAO:
        return 3;
      default:
        return 100;
    }
  }
}
