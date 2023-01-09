import 'package:flutter/material.dart';

class TextStyleBordered extends TextStyle {
  final fontSize, textColor, borderSize, borderColor, fontWeight;

  TextStyleBordered({
    @required this.fontSize,
    @required this.textColor,
    @required this.borderColor,
    @required this.borderSize,
    this.fontWeight,
  }) : super(
          inherit: true,
          fontSize: fontSize ?? 14.0,
          color: textColor ?? Colors.black,
          fontWeight: fontWeight,
          shadows: [
            Shadow(
                // bottomLeft
                offset: Offset(-(borderSize ?? 0.1), -(borderSize ?? 0.1)),
                color: borderColor ?? Colors.white),
            Shadow(
                // bottomRight
                offset: Offset(borderSize ?? 0.1, -(borderSize ?? 0.1)),
                color: borderColor ?? Colors.white),
            Shadow(
                // topRight
                offset: Offset(borderSize ?? 0.1, borderSize ?? 0.1),
                color: borderColor ?? Colors.white),
            Shadow(
                // topLeft
                offset: Offset(-(borderSize ?? 0.1), borderSize ?? 0.1),
                color: borderColor ?? Colors.white),
          ],
        );
}
