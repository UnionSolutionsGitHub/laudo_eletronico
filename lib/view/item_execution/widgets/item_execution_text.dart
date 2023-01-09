import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/item_execution/item_execution_bloc.dart';
import 'package:laudo_eletronico/common/util/ui_utils.dart';
import 'package:laudo_eletronico/model/check_item.dart';
import 'package:laudo_eletronico/model/input_type.dart';

class LaudoChecklistItemText extends StatefulWidget {
  final CheckItem checkItem;
  final ItemExecutionBloc bloc;
  LaudoChecklistItemText(this.checkItem, this.bloc);

  @override
  _LaudoChecklistItemTextState createState() => _LaudoChecklistItemTextState();
}

class _LaudoChecklistItemTextState extends State<LaudoChecklistItemText> {
  TextEditingController controller;

  @override
  void initState() {
    controller = textControllerFor(
      widget.checkItem.inputType,
      text: widget.checkItem.checkedItem,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              widget.checkItem.type,
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              keyboardType: keyboardTypeFor(widget.checkItem.inputType),
              onChanged: (text) {
                final shouldUpdateAnswer =
                    widget.checkItem.inputType == InputType.date
                        ? text.isEmpty || text.length == 5
                        : true;
                if (shouldUpdateAnswer) {
                  widget.bloc.onAnswerText(
                      widget.checkItem.type, controller.text, widget.checkItem.inputType);
                }
              },
              decoration: InputDecoration(
                hintText: widget.checkItem.placeholder,
              ),
            ),
          )
        ],
      ),
    );
  }
}
