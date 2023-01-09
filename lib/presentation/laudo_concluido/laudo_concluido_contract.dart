abstract class LaudoConcluidoViewContract {
  notifyDataChanged();
  showErrorMessage({String erroMessage = "laudo_concluido_alert_erro_message"});
  navigateToPendentes();
  naviteToNovaVistoria();
}

abstract class LaudoConcluidoPresenterContract {
  bool get isSyncing;
  String get mensage;
  checkRedirectToView();
}