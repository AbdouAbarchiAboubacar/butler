import 'package:butler/app.dart';
import 'package:butler/providers/auth_provider.dart';
import 'package:butler/providers/setting_provider.dart';
import 'package:butler/services/connexion.dart/connectivity_status.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:algolia/algolia.dart';

const String locaHostAddress = "192.168.88.117";

///
/// Initiate static Algolia once in your project.
///
class AlgoliaClass {
  static Algolia algolia = const Algolia.init(
    applicationId: '6TADKOU0ZU',
    apiKey: 'c6258ee867ce62e8b68dd3a1691c2243',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //
  // FirebaseUseEmulator();
  //
  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  //
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (context) => SettingsProvider(),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider(),
          ),
        ],
        child: App(connectivityService: () => ConnectivityStatus.offline),
      ),
    );
  });
}
