import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/configuration.dart';

abstract class ListagemConfiguracoesViewContract {
  void notifyDataChanged();
  navigatorPush(MaterialPageRoute route, bool newflow);
}

abstract class ListagemConfiguracoesPresenterContract {
  TextEditingController get queryController;
  List<Configuration> get configurations;
  bool get isLoading;
  Function(String) get onQueryChanged;
  onSelectedItemListener(int index);
}