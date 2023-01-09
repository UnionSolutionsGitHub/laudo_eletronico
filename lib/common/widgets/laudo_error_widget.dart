import 'dart:math';

import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/main.dart';
import 'package:standard/widgets/round_button.dart';

class LaudoErrorWidget extends StatelessWidget {
  LaudoErrorWidget();

  @override
  Widget build(BuildContext context) {
    final dimension = _getIconDimension(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(defaultMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/erro.png',
                width: dimension,
                height: dimension,
              ),
            ),
            SizedBox(
              height: tripleSpace,
            ),
            Text(
              GlobalizationStrings.of(context).value("error_widget_title"),
              style: TextStyle(fontSize: titleTextSize),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: doubleSpace,
            ),
            Text(
              GlobalizationStrings.of(context).value("error_widget_message"),
              style: TextStyle(fontSize: mediumTextSize),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 40.0,
            ),
            SizedBox(
              width: double.infinity,
              child: RoundButton(
                title: GlobalizationStrings.of(context)
                    .value("error_widget_return_button"),
                textColor: Colors.white,
                color: AppColors.primary,
                onPressed: () => _goToHome(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.VISTORIAS_PENDENTES, (route) => false);
  }

  double _getIconDimension(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return min(size.width, size.height) *
        0.25; // 25% of the smaller screen dimension
  }
}
