import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/text_style_bordered.dart';

class LaudoCameraTabViewTopItem extends StatelessWidget {
  final Size _screenSize;
  final String _description;

  LaudoCameraTabViewTopItem(this._screenSize, this._description);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
        width: _screenSize.width / 1.4,
        child: Center(
          child: Text(
            _description,
            textAlign: TextAlign.center,
            style: TextStyleBordered(
              borderColor: Colors.black,
              fontSize: 18,
              textColor: Colors.white,
              borderSize: 0.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
