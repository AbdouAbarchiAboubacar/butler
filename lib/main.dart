import 'package:butler/app.dart';
import 'package:butler/providers/setting_provider.dart';
import 'package:butler/services/connexion.dart/connectivity_status.dart';
import 'package:butler/ui/firebase/firebase_emulator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const String locaHostAddress = "192.168.88.90";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //
  FirebaseUseEmulator();
  //
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (context) => SettingsProvider(),
          ),
        ],
        child: App(connectivityService: () => ConnectivityStatus.offline),
      ),
    );
  });
}
