import 'package:flutter/material.dart';

class LaudoChecklistAlertListController {
  TextEditingController _txfdSearchBarQueryController;

  LaudoChecklistAlertListController() {
    _txfdSearchBarQueryController = TextEditingController();
  }

  TextEditingController get txfdSearchBarQueryController => _txfdSearchBarQueryController;
}