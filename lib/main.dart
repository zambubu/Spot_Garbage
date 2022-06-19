import 'package:authentifaction_app/screens/home_screen.dart';
import 'package:authentifaction_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Spot Garbage',
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            // if (userSnapshot.connectionState == ConnectionState.waiting) {
            //   return const SplashScreen();
            // }
            if (userSnapshot.hasData) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ));
  }
}
