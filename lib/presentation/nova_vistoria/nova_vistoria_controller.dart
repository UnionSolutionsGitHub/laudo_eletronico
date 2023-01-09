import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/flutter_masked_text.dart';

class NovaVistoriaController {
  final FocusNode _txfdCarPlateFocusNode = FocusNode();

  final MaskedTextController _txfdCarPlateController = MaskedTextController(mask: "AAA-0@00");

  bool txfdCarPlateEnabled = true;

  FocusNode get txfdCarPlateFocusNode => _txfdCarPlateFocusNode;

  MaskedTextController get txfdCarPlateController => _txfdCarPlateController;

  setFocus(BuildContext context, FocusNode focusNode) {
    _txfdCarPlateFocusNode.unfocus();
    FocusScope.of(context).requestFocus(focusNode);
  }
}
