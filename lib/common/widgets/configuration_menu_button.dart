import 'package:flutter/material.dart';
import 'package:laudo_eletronico/main.dart';

class ConfigurationMenuButton extends StatelessWidget {
  ConfigurationMenuButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.settings),
        onPressed: () async {
          Navigator.of(context).pushNamed(Routes.CONFIGURATION);
        });
  }
}
