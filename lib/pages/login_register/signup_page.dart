import 'package:flutter/material.dart';
import 'login_page.dart';
import '../account_setup/iam_page.dart';
import '../account_setup/verification_page.dart';
import '../../services/auth_service.dart';
import 'package:my_app/components/my_button.dart';
import 'package:my_app/components/my_textfield.dart';
import 'package:my_app/components/square_tile.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign user up method
  Future<void> signUserUp(BuildContext context) async {
    final authService = AuthService();

    await authService.signup(
      email: emailController.text,
      password: passwordController.text,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo
              Image.asset(
                'lib/images/logo.png',
                height: 100,
              ),

              const SizedBox(height: 30),

              // Sign up to continue text
              const Text(
                'Sign up to continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 25),

              // Email text field
              MyTextField(
                controller: emailController,
                hintText: 'Enter your email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Password text field
              MyTextField(
                controller: passwordController,
                hintText: 'Enter your password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // Sign up button
              MyButton(
                onTap: () => signUserUp(context),
              ),

              const SizedBox(height: 30),

              // Divider with text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or sign up with',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Social media sign up buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SquareTile(imagePath: 'lib/images/fb.png'),
                  SizedBox(width: 25),
                  SquareTile(imagePath: 'lib/images/google.png'),
                  SizedBox(width: 25),
                  SquareTile(imagePath: 'lib/images/apple.png'),
                ],
              ),

              const SizedBox(height: 30),

              // Already a member? Sign in now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Sign in now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Terms of use and privacy policy
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Terms of use',
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class SquareTile extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const SquareTile({
    super.key,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.pink,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            imagePath,
            height: 40,
          ),
        ),
      ),
    );
  }
}
