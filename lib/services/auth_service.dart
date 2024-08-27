import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../pages/account_setup/iam_page.dart';
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

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const IamPage(),
        ),
      );

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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const IamPage(),
        ),
      );

    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      _showToast(message);
    } catch (e) {
      _showToast('An error occurred. Please try again.');
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
    await Future.delayed(const Duration(seconds: 1));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(),
      ),
    );
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
}
