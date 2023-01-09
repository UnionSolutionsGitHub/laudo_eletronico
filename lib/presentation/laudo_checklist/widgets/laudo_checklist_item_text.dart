import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/flutter_masked_text.dart';
import 'package:laudo_eletronico/common/util/ui_utils.dart';
import 'package:laudo_eletronico/model/input_type.dart';
import 'package:laudo_eletronico/model/item_configuration.dart';
import 'package:laudo_eletronico/presentation/laudo_checklist/laudo_checklist_contract.dart';

class LaudoChecklistItemText extends StatelessWidget {
  final LaudoChecklistPresenterContract _presenter;
  final ItemConfiguration item;

  LaudoChecklistItemText(this._presenter, int _index)
      : item = _presenter.items[_index];

  @override
  Widget build(BuildContext context) {
    final controller = textControllerFor(
          item.inputType,
          text: _presenter.textAnswer(item),
        );
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardTypeFor(item.inputType),
        onChanged: (value) {
          final shouldUpdateAnswer = item.inputType == InputType.date
              ? value.isEmpty || value.length == 5
              : true;
          if (shouldUpdateAnswer) {
            _presenter.onAnswerText(item, controller.text);
          }
        },
        decoration: InputDecoration(
          hintText: item.placeholder,
        ),
      ),
    );
  }

  /* TextEditingController _textController() {
    TextEditingController controller;

    switch (item.inputType) {
      case InputType.date:
        controller = MaskedTextController(
            mask: "00/00", text: _presenter.textAnswer(item));

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
      default:
        controller = TextEditingController(text: _presenter.textAnswer(item));
        break;
    }

    return controller;
  } */
}
