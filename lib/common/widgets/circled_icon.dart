import 'package:flutter/material.dart';

class CircledIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  CircledIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Icon(
        this.icon,
        color: this.color,
        size: 20.0,
      ),
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
      padding: EdgeInsets.all(0.0),
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: this.color,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(18.0),
      ),
    );
  }
}
