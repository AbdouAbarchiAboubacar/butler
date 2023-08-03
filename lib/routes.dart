import 'package:flutter/material.dart';
import 'package:butler/ui/main/home.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiate this object
  static const String home = '/home';
  static const String onboarding = '/onboarding';

  static final routes = <String, WidgetBuilder>{
    home: (BuildContext context) => HomePage(),
  };
}
