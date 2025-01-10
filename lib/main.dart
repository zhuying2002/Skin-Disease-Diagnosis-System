import 'package:flutter/material.dart';
import 'package:skin_disease_model_flask_app/pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_disease_model_flask_app/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScaffoldMessenger(
        key: messengerKey,
        child: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Stream that listens to the authentication state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while waiting for the authentication state
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle any errors that might occur during the authentication process
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // Check if the user is authenticated
          final User? user = snapshot.data;
          if (user != null) {
            if (user.metadata.creationTime == user.metadata.lastSignInTime) {
              // User just registered, redirect to login page
              return LoginPage();
            } else {
              // User is signed in, navigate to home page
              return HomePage();
            }
          } else {
            // If user is not signed in, navigate to login page
            return LoginPage();
          }
        }
      },
    );
  }
}
