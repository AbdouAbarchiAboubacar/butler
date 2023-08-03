import 'package:flutter/material.dart';
import 'package:butler/providers/setting_provider.dart';
import 'package:butler/services/connexion.dart/connectivity_status.dart';
import 'package:butler/ui/main/home.dart';
import 'package:provider/provider.dart';
import 'auth_widget_builder.dart';

class App extends StatelessWidget {
  const App({Key? key, required this.connectivityService}) : super(key: key);

  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing

  // This widget is the root of your application.
  final ConnectivityStatus Function() connectivityService;
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, settingsProvider, __) {
        return AuthWidgetBuilder(
          connectivityService: connectivityService,
          builder: (BuildContext context, Future<bool> isInstalled) {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: "Bulter",
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: HomePage());
          },
        );
      },
    );
  }
}
