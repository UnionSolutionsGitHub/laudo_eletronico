import 'package:flutter/material.dart';
import 'package:laudo_eletronico/common/widgets/text_style_bordered.dart';

class LaudoCameraTabViewProgress extends StatelessWidget {
  final Size _screenSize;
  final int _index, _length;

  LaudoCameraTabViewProgress(this._screenSize, this._index, this._length);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _screenSize.width / 1.4,
        child: Center(
          child: Text(
            "$_index/$_length",
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
