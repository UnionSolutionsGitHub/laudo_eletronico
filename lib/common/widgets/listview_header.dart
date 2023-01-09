import 'package:flutter/material.dart';

import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';

class ListviewHeader extends StatelessWidget {
  final bool showHeader;
  final String globalizationKey;

  ListviewHeader({
    @required this.showHeader,
    @required this.globalizationKey,
  });

  @override
  Widget build(BuildContext context) {
    return (this.showHeader)
        ? Container(
            padding: EdgeInsets.all(20),
            child: Text(
              GlobalizationStrings.of(context).value(this.globalizationKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )
        : Container();
  }
}
