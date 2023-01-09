import 'package:flutter/material.dart';

class SearchTextResult extends StatelessWidget {
  final String text, searchText;
  final Color textColor;
  final double fontSize;

  SearchTextResult(this.text, this.searchText, {this.textColor, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: this.text.substring(0, this.searchText.length),
        style: TextStyle(
          color: this.textColor ?? Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: this.fontSize ?? 16,
        ),
        children: [
          TextSpan(
            text: this.text.substring(this.searchText.length),
            style: TextStyle(
                color: this.textColor?.withAlpha(150) ?? Colors.grey,
                fontSize: this.fontSize ?? 16),
          ),
        ],
      ),
    );
  }
}
