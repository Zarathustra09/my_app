import 'package:flutter/material.dart';
import 'package:my_app/pages/Main%20page/matching_page.dart';
import 'pages/login_register/signup_page.dart';
import 'pages/login_register/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/account_setup/iam_page.dart';
import 'pages/account_setup/getusername_page.dart';
import 'pages/account_setup/yourinterest_page.dart';
import 'services/auth_service.dart';
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return LoginPage();
            } else {
              return FutureBuilder<Map<String, bool>>(
                future: AuthService().checkUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    final userData = snapshot.data!;
                    if (!userData['hasUsername']! || !userData['hasBirthday']! || !userData['hasImageUrl']!) {
                      return const GetUsernamePage();
                    } else if (!userData['hasGender']!) {
                      return const IamPage();
                    } else if (!userData['hasInterests']!) {
                      return const YourInterestsPage();
                    } else {
                      return const MatchingPage();
                    }
                  } else {
                    return const Center(child: Text('Error loading user data'));
                  }
                },
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}