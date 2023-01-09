import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:laudo_eletronico/model/input_type.dart';

TextInputType keyboardTypeFor(InputType inputType) {
  switch (inputType) {
    case InputType.date:
    case InputType.number:
      return TextInputType.numberWithOptions(decimal: false, signed: false);
    case InputType.text:
    case InputType.chassi:
      return TextInputType.text;
    default:
      return null;
  }
}

TextEditingController textControllerFor(InputType inputType,
    {@required String text}) {
  TextEditingController controller;
  switch (inputType) {
    case InputType.date:
      controller = MaskedTextController(mask: "00/00", text: text);

      controller.addListener(() {
        if (controller.text.length == 1 && int.parse(controller.text) > 1) {
          final newText = controller.text.padLeft(2, '0');

          controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
          return;
        }

        if (controller.text.length == 2) {
          if (int.parse(controller.text) < 1 ||
              int.parse(controller.text) > 12) {
            final newText =
                controller.text.substring(0, controller.text.length - 1);

            controller.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: newText.length),
            );
            return;
          }
        }
      });
      break;
    case InputType.chassi:
      controller = MaskedTextController(mask: "@@@@@@@@@@@@@@@@@", text: text);
      break;
    case InputType.number:
      controller = TextEditingController(text: text);
      controller.addListener(() {
        final notDigit = RegExp(r'[^0-9]');
        final text = controller.text;
        final newText = text.replaceAll(notDigit, '');
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      });
      break;
    default:
      controller = TextEditingController(text: text);
      break;
  }
  return controller;
}
