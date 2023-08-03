import 'package:flutter/material.dart';
import 'package:butler/caches/shared_preference_helper.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferenceHelper? _sharedPrefsHelper;
  SettingsProvider() {
    _sharedPrefsHelper = SharedPreferenceHelper();
  }
  ////// First Install provider
  ///
  ///
  // ignore: unused_field
  bool _isInstall = false;

  Future<bool> get isInstalled async {
    bool isInstall = await _sharedPrefsHelper!.isInstalled;
    _isInstall = isInstall;
    return isInstall;
  }

  Future<void> restartApp(bool isInstalled) async {
    await _sharedPrefsHelper!.appIsInstalled(isInstalled);
    await _sharedPrefsHelper!.isInstalled.then((isInstalledStatus) {
      _isInstall = isInstalledStatus;
    });
    notifyListeners();
  }
}
