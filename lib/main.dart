import 'package:flutter/material.dart';
import 'pages/login_register/signup_page.dart';
import 'pages/login_register/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/account_setup/iam_page.dart';
import 'pages/account_setup/yourinterest_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build (BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasError){
            return const Text('Something went wrong');
          }

          if(snapshot.connectionState == ConnectionState.active){
            if(snapshot.data == null){
              return LoginPage();
            } else {
              return YourInterestsPage();
            }
          }
          return CircularProgressIndicator();
        }
      ),
    );
  }
  }