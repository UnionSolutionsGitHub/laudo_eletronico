import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';

class RoundIconButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Function() onPressed;

  RoundIconButton({this.color, this.icon, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      child: RawMaterialButton(
            child: Padding(
              padding: const EdgeInsets.all(singleSpace + 4),
              child: Icon(icon, color: Colors.white,),
            ),
            onPressed: onPressed,
            shape: CircleBorder(),
            fillColor: color,
          ),
    );
  }
}