import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';

class LaudoCameraButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      //alignment: Alignment.bottomCenter,
      margin: EdgeInsets.fromLTRB(15, 15, 15, 75),
      width: double.infinity,
      child: Container(
        height: 80,
        child: new RawMaterialButton(
          shape: new CircleBorder(
              side: BorderSide(
            width: 5,
            color: AppColors.primary,
          )),
          elevation: 1.0, 
          onPressed: null,
          //fillColor: Colors.redAccent,
        ),
      ),
    );
  }
}
