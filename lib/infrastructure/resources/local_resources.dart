import 'package:laudo_eletronico/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalResources {
  static SharedPreferences _resources;

  Future<LocalResources> instance() async {
    if (_resources == null) {
      _resources = await SharedPreferences.getInstance();
    }
    if (token != null) {
      _Keys.user = User.fromToken(token);
    } 
    return this;
  }

  String get token => _resources.getString(_Keys.token);
  set token(String token) {
    if (token?.isNotEmpty != false) {
      _resources.remove(_Keys.token);
    }
    _resources.setString(_Keys.token, token);
    // Stores the user to be used when fetching user-dependent information
    if (token == null) {
      _Keys.user = null;
    } else {
      _Keys.user = User.fromToken(token);
    }
  }

  bool get isNewFlowEnabled {
    bool value = _resources.getBool(_Keys.isNewFlowEnabled);
    if (value == null) {
      isNewFlowEnabled = false;
      value = _resources.getBool(_Keys.isNewFlowEnabled);
    }
    return value;
  }

  set isNewFlowEnabled(bool isNewFlowEnabled) =>
      _resources.setBool(_Keys.isNewFlowEnabled, isNewFlowEnabled);

  bool get tutorialCompleted => _resources.getBool(_Keys.tutorialCompleted);
  set tutorialCompleted(bool tutorialCompleted) =>
      _resources.setBool(_Keys.tutorialCompleted, tutorialCompleted);
}

/// LocalResources keys
class _Keys {
  static User user;

  static const String token = 'token';

  // Any information dependent on the user should be stored with
  // a user-dependent key, like below:
  static String get isNewFlowEnabled => '${user.id}_is_new_flow_enabled';
  static String get tutorialCompleted => '${user.id}_tutorial_completed';
}
