import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/widgets.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';

class ConfigurationBloc extends BlocBase {
  final LocalResources localResources;
  final PackageInfo packageInfo;
  final User user;

  final _isNewFlowEnabled = BehaviorSubject<bool>();
  final _version = BehaviorSubject<String>();
  final _username = BehaviorSubject<String>();

  //
  // Inputs
  //
  Function(bool) get onSwitchToggled => (value) {
        localResources.isNewFlowEnabled = value;
        _isNewFlowEnabled.add(value);
      };

  //
  // Outputs
  //
  Stream<bool> get isNewFlowEnabled => _isNewFlowEnabled.stream;
  Stream<String> get version => _version.stream;
  Stream<String> get username => _username.stream;

  ConfigurationBloc({
    @required this.localResources,
    @required this.packageInfo,
    @required this.user,
  }) {
    _configureNewFlowSwitch();
    _configureVersion();
    _configureUsername();
  }

  void _configureNewFlowSwitch() {
    bool newFlowEnabled = localResources.isNewFlowEnabled;
    if (newFlowEnabled == null) {
      newFlowEnabled = false;
      localResources.isNewFlowEnabled = newFlowEnabled;
    }
    _isNewFlowEnabled.add(newFlowEnabled);
  }

  void _configureVersion() {
    final version = packageInfo.version;
    _version.add(version);
  }

  void _configureUsername() {
    _username.add(user.name);
  }

  logout() => localResources.token = null;

  @override
  void dispose() {
    _isNewFlowEnabled.close();
    _version.close();
    _username.close();
    super.dispose();
  }
}
