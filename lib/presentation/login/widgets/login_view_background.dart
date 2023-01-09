import 'package:flutter/material.dart';

import '../../../infrastructure/resources/colors.dart';

class LoginViewBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  Color.fromRGBO(0, 53, 91, 1),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.light,
            ),
          ),
        ),
      ],
    );
  }
}
