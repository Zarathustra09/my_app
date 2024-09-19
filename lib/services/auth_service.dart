import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/toaster.dart';
import '../pages/Main page/matching_page.dart';
import '../pages/account_setup/getusername_page.dart';
import '../pages/account_setup/iam_page.dart';
import '../pages/account_setup/yourinterest_page.dart';
import '../pages/login_register/login_page.dart';
import '../pages/Main page/matches_page.dart';

class AuthService {
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const IamPage(),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      _showToast(message);
    } catch (e) {
      _showToast('An error occurred. Please try again.');
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      print('Attempting to sign in with email: $email');
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        print('User signed in successfully: ${user.uid}');
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          print('User data retrieved: $data');
          final userData = {
            'hasBirthday': data['birthday'] != null,
            'hasImageUrl': data['imageUrl'] != null,
            'hasUsername': data['username'] != null,
            'hasGender': data['gender'] != null,
            'hasInterests': data['interests'] != null && (data['interests'] as List).isNotEmpty,
          };

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentUser = FirebaseAuth.instance.currentUser;if (currentUser == null) {
              print('User not logged in. Redirecting to LoginPage');
              Toaster.showToast('The inputted credentials do not match our records');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              return;
            }

            if (!userData['hasUsername']! || !userData['hasBirthday']! || !userData['hasImageUrl']!) {
              print('Redirecting to GetUsernamePage');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GetUsernamePage()),
              );
            } else if (!userData['hasGender']!) {
              print('Redirecting to IamPage');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IamPage()),
              );
            } else if (!userData['hasInterests']!) {
              print('Redirecting to YourInterestsPage');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => YourInterestsPage()),
              );
            } else {
              print('Redirecting to MatchingPage');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MatchingPage()),
              );
            }
          });
        } else {
          print('User document does not exist');
        }
      } else {
        print('User is null after sign in');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else if (e.code == 'too-many-requests') {
        message = 'Access to this account has been temporarily disabled due to many failed login attempts. Please try again later or reset your password.';
      }
      print('FirebaseAuthException: $e');
      Toaster.showToast(message);
    } catch (e) {
      print('Exception: $e');
      Toaster.showToast('An error occurred. Please try again.');
    }
  }

  Future<void> signout({
    required BuildContext context,
  }) async {
    if (GoogleSignIn().currentUser != null) {
      await GoogleSignIn().signOut();
    }

    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print('Failed to disconnect on signout: $e');
    }

    await FirebaseAuth.instance.signOut();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(),
        ),
      );
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.pink, // Pink background
      textColor: Colors.white, // White text
      fontSize: 14.0,
      timeInSecForIosWeb: 1,
      // Custom toast style using a container
      webBgColor: "linear-gradient(to right, #FF4081, #F50057)", // Gradient for web
      webPosition: "center",
    );
  }

  Future<Map<String, bool>> checkUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'hasBirthday': data['birthday'] != null,
          'hasImageUrl': data['imageUrl'] != null,
          'hasUsername': data['username'] != null,
          'hasGender': data['gender'] != null,
          'hasInterests': data['interests'] != null && (data['interests'] as List).isNotEmpty,
        };
      }
    }
    return {
      'hasBirthday': false,
      'hasImageUrl': false,
      'hasUsername': false,
      'hasGender': false,
      'hasInterests': false,
    };
  }
}
