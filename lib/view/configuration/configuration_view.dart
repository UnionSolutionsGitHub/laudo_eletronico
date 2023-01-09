import 'package:flutter/material.dart';
import 'package:laudo_eletronico/bloc/configuration/configuration_bloc.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';
import 'package:laudo_eletronico/infrastructure/resources/globalization_strings.dart';
import 'package:laudo_eletronico/main.dart';

class ConfigurationView extends StatelessWidget {
  final ConfigurationBloc bloc;

  ConfigurationView({@required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: largeMargin / 2),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _buildVersionHeader(),
            SizedBox(
              height: mediumMargin,
            ),
            _buildListHeader(),
            _buildConfigurationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: doubleSpace, bottom: halfSpace),
        child: Text(
          'Configurações',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionHeader() {
    return StreamBuilder<String>(
      stream: bloc.version,
      builder: (context, snapshot) {
        final version = snapshot.data;
        return Center(
          child: Column(
            children: <Widget>[
              Image.asset(
                './assets/images/logo_white.png',
                color: Colors.black,
                width: 64,
                height: 64,
              ),
              SizedBox(height: tripleSpace),
              Text(GlobalizationStrings.of(context).value("main_title")),
              SizedBox(height: singleSpace),
              Text("Versão ${version ?? ''}"),
              SizedBox(height: singleSpace),
              Text(GlobalizationStrings.of(context).value("copyright")),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigurationsList() {
    return StreamBuilder<bool>(
      stream: bloc.isNewFlowEnabled,
      builder: (context, snapshot) {
        final isNewFlowEnabled = snapshot.data;
        if (isNewFlowEnabled == null) return Container();
        return ListView.builder(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text(GlobalizationStrings.of(context)
                      .value('config_continuous_flow_title')),
                  subtitle: Text(GlobalizationStrings.of(context)
                      .value('config_continuous_flow_subtitle')),
                  trailing: Switch(
                    value: isNewFlowEnabled,
                    onChanged: bloc.onSwitchToggled,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text(GlobalizationStrings.of(context)
                      .value('config_tutorial_title')),
                  subtitle: Text(GlobalizationStrings.of(context)
                      .value('config_tutorial_subtitle')),
                  onTap: () => Navigator.of(context).pushNamed(Routes.TUTORIAL),
                );
                break;
              case 2:
                return ListTile(
                  title: Text(GlobalizationStrings.of(context)
                      .value('config_exit_title')),
                  onTap: () {
                    bloc.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.LOGIN,
                      (Route<dynamic> route) => false,
                    );
                  },
                  subtitle: StreamBuilder<Object>(
                      stream: bloc.username,
                      builder: (context, snapshot) {
                        final username = snapshot.data;
                        final text = username != null
                            ? 'Você entrou como $username'
                            : '';
                        return Text(text);
                      }),
                );
                break;
            }
          },
        );
      },
    );
  }
}
