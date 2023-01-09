import 'package:flutter/material.dart';
import 'package:laudo_eletronico/model/laudo.dart';

abstract class VistoriasPendentesViewContract {
  void notifyDataChanged();
  navigatorPush(MaterialPageRoute route);
  showProgressIndeterminate();
  hideProgressIndeterminate();
}

abstract class VistoriasPendentesPresenterContract {
  bool get isLoading;
  bool get isInSelectionMode;
  bool get isEmpty;
  int get selectedCount;
  cancelSelection();
  Future<bool> deleteSelected();
  TextEditingController get queryController;
  List<Laudo> get laudos;
  Function(String) get onQueryChanged;
  onItemClicked(int index);
  onChangeItemSelection(int index);
  bool isItemSelected(int index);
  reloadData();
  dispose();
  bool get isNewFlowEnabled;
  String newFlowStatus(Laudo laudo);
}
