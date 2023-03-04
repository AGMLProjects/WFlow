import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/actions/adddevice/AddDevicePage.dart';
import 'package:wflowapp/main/actions/adddevice/FinishAddDevicePage.dart';
import 'package:wflowapp/main/actions/adddevice/ScannerPage.dart';
import 'package:wflowapp/main/actions/addhouse/AddHousePage.dart';
import 'package:wflowapp/main/actions/edithouse/EditHousePage.dart';
import 'package:wflowapp/main/MainPage.dart';
import 'package:wflowapp/main/actions/viewhouse/HousePage.dart';
import 'package:wflowapp/splash/SplashPage.dart';
import 'package:wflowapp/user/LoginPage.dart';
import 'package:wflowapp/user/RegisterPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainPage(),
        '/addHouse': (context) => const AddHousePage(),
        '/addDevice': (context) => const AddDevicePage(),
        '/scan': (context) => const ScannerPage(),
        '/finishAddDevice': (context) => const FinishAddDevicePage(),
        '/house': (context) => const HousePage(),
        '/editHouse': (context) => const EditHousePage()
      },
    );
  }
}
