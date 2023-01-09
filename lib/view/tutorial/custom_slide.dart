import 'package:flutter/material.dart';

class CustomSlide extends StatelessWidget {
  final Widget upperWidget, lowerWidget;
  final Color backgroundColor;
  CustomSlide({
    @required this.upperWidget,
    @required this.lowerWidget,
    @required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final footerHeight = 70.0;
    final height = size.height - footerHeight;
    return Container(
      child: Center(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 0.1 * height),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
              child: Container(
                alignment: Alignment.bottomCenter,
                child: upperWidget,
                height: height * 0.7,
              ),
            ),
            SizedBox(height: 0.05 * height),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: Container(
                child: lowerWidget,
                height: height * 0.15,
              ),
            ),
            SizedBox(height: footerHeight),
          ],
        ),
      ),
      color: backgroundColor,
    );
  }
}
