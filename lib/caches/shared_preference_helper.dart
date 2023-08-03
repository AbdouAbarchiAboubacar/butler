import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  Future<SharedPreferences>? _sharedPreference;
  static const String firstInstall = "firstInstall";

  SharedPreferenceHelper() {
    _sharedPreference = SharedPreferences.getInstance();
  }

  //First Install
  Future<void> appIsInstalled(bool value) {
    return _sharedPreference!
        .then((prefs) => prefs.setBool(firstInstall, value));
  }

  Future<bool> get isInstalled {
    return _sharedPreference!.then((prefs) {
      return prefs.getBool(firstInstall) ?? false;
    });
  }
}
