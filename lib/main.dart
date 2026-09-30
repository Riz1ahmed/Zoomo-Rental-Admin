import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/session.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Session.instance.init();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Bike Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Session.instance.isLoggedIn
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
