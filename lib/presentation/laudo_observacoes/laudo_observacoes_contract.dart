import 'package:laudo_eletronico/presentation/laudo_observacoes/laudo_observacoes_controller.dart';

abstract class LaudoObservacoesViewContract {
	notifyDataChanged();
}

abstract class LaudoObservacoesPresenterContract {
	LaudoObservacoesController get controller;
	Future saveNotes();
}