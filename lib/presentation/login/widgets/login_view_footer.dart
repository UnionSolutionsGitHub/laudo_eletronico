import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../login_contract.dart';
import 'package:laudo_eletronico/infrastructure/resources/colors.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';

class LoginViewFooter extends StatelessWidget {
  final LoginPresenterContract presenter;

  final StreamController<String> _stream = StreamController<String>();

  LoginViewFooter(this.presenter) {
    PackageInfo.fromPlatform().then((infos) {
      _stream.sink.add(infos.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.bottomCenter,
      child: StreamBuilder<String>(
        stream: _stream.stream,
        initialData: "",
        builder: (BuildContext streamContext, AsyncSnapshot<String> snapshot) =>
            Text(
              "${GlobalizationStrings.of(context).value("login_footer_text")} ${snapshot.data}",
              style: TextStyle(color: AppColors.primary, fontSize: 11.0),
            ),
      ),
    );
  }
}
