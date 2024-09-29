import 'package:flutter/material.dart';
import 'package:my_app/components/my_button.dart';
import 'package:my_app/components/my_textfield.dart';
import 'package:my_app/components/square_tile.dart';
import 'package:my_app/pages/Main%20page/matching_page.dart';
import 'package:my_app/pages/account_setup/verification_page.dart';
import 'package:my_app/pages/login_register/signup_page.dart' as signup;
import 'package:my_app/pages/login_register/forgot_password_page.dart';
import '../../components/toaster.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../account_setup/iam_page.dart';
import '../account_setup/getusername_page.dart';
import '../account_setup/yourinterest_page.dart';
import '../background.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) async {
    final authService = AuthService();
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Validate email and password
    if (email.isEmpty || password.isEmpty) {
      print('Email or password is empty');
      Toaster.showToast('Please enter both email and password');
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      print('Invalid email format: $email');
      Toaster.showToast('Invalid email format');
      return;
    }

    try {
      print('Attempting to sign in with email: $email');
      await authService.signin(
        email: email,
        password: password,
        context: context,
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('User not logged in. Redirecting to LoginPage');
        Toaster.showToast('The inputted credentials do not match our records');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return;
      }

      final userData = await authService.checkUserData();
      print('User data retrieved: $userData');
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
    } catch (e) {
      print('Error during sign-in: $e');
      Toaster.showToast('Error during sign-in. Please try again.');
    }
  }

  signInWithGoogle(BuildContext context) async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = googleSignIn.currentUser;

      if (googleUser != null) {
        await googleSignIn.signOut();
      }

      googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final userData = await AuthService().checkUserData();
      if (!userData['hasUsername']! ||
          !userData['hasBirthday']! ||
          !userData['hasImageUrl']!) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GetUsernamePage()),
        );
      } else if (!userData['hasGender']!) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IamPage()),
        );
      } else if (!userData['hasInterests']!) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => YourInterestsPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MatchingPage()),
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Background.gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'lib/icons/LOGO.png',
                  width: constraints.maxWidth * 0.4, // make the logo responsive
                ),

                SizedBox(height: constraints.maxHeight * 0.000001), // make the spacing responsive

                // Login Form
                Container(
                  width: constraints.maxWidth * 0.8, // make the form responsive
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Username Field
                        MyTextField(
                          controller: usernameController,
                          hintText: "Email Address",
                          obscureText: false,
                        ),
                        SizedBox(height: 15),

                        // Password Field
                        MyTextField(
                          controller: passwordController,
                          hintText: "Password",
                          obscureText: true,
                        ),
                        SizedBox(height: 15),

                        // Sign-in Button
                        MyButton(
                          onTap: () => signUserIn(context),
                          text: 'Sign In',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: constraints.maxHeight * 0.03), // make the spacing responsive

                // Forgot Password
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                // Or Divider
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(width: 55, height: 1, color: Colors.white),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        "Or",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(width: 55, height: 1, color: Colors.white),
                  ],
                ),

                SizedBox(height: constraints.maxHeight * 0.02), // make the spacing responsive

                // Social Media Login Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'lib/images/google.png',
                      onTap: () => signInWithGoogle(context),
                    ),
                    SizedBox(width: 20),
                    SquareTile(imagePath: 'lib/images/fb.png'),
                  ],
                ),

                SizedBox(height: constraints.maxHeight * 0.05), // make the spacing responsive

                // Register Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => signup.SignUpPage()),
                        );
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}