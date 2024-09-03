import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/components/my_button.dart'; // Import MyButton

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to receive a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: () => sendPasswordResetEmail(context),
              text: 'Send Reset Email',
            ),
          ],
        ),
      ),
    );
  }
}