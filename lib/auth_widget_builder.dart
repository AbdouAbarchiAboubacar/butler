import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/services/firebase/realtime_database.dart';
import 'package:flutter/material.dart';
import 'package:butler/providers/setting_provider.dart';
import 'package:butler/services/connexion.dart/connectivity_service.dart';
import 'package:butler/services/connexion.dart/connectivity_status.dart';
import 'package:provider/provider.dart';

class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({
    Key? key,
    required this.builder,
    required this.connectivityService,
  }) : super(key: key);

  final Widget Function(BuildContext, Future<bool>) builder;
  final ConnectivityStatus Function() connectivityService;

  @override
  Widget build(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: true);
    return MultiProvider(
      providers: [
        Provider<FirestoreDatabase>(
          create: (context) => FirestoreDatabase(),
        ),
        Provider<RealTimeDatabase>(
          create: (context) => RealTimeDatabase(),
        ),
        Provider<FirebaseFileStorage>(
          create: (context) => FirebaseFileStorage(),
        ),
        StreamProvider<ConnectivityStatus>(
          initialData: ConnectivityStatus.offline,
          create: (context) =>
              ConnectivityService().connectionStatusController.stream,
        ),
      ],
      child: builder(context, settingsProvider.isInstalled),
    );
  }
}
