import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert' show json, base64, ascii;
import 'package:flutter/services.dart';
import 'package:stock_take/welcome_page.dart';
import 'package:permission_handler/permission_handler.dart';

import 'db_config.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    DBProvider.db.initDB(newVersion: 1);
    DBProvider.db.insertDefaultUser();
    DBProvider.db.insertDefaultSettings();
    requestStoragePermission();
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.status == PermissionStatus.granted) {
      return true;
    } else {
      final PermissionStatus result = await Permission.storage.request();
      return result == PermissionStatus.granted;
    }
  }

  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: "Stock Take",
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
