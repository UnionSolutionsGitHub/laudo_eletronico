import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';

class LaudoSumarioButton extends StatelessWidget {
  final String _text;
  final IconData icon;
  final Function _onSelectedItemListener;

  LaudoSumarioButton(this._text, this._onSelectedItemListener, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: _onSelectedItemListener,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  this.icon != null
                      ? Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Icon(this.icon),
                        )
                      : Container(),
                  Text(
                    _text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 4,
        )
        // Divider(
        //   color: Colors.grey,
        //   height: 2.0,
        // ),
      ],
    );
  }
}
