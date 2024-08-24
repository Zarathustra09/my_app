import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'yourinterest_page.dart';

class GetUsernamePage extends StatefulWidget {
  const GetUsernamePage({super.key});

  @override
  _GetUsernamePageState createState() => _GetUsernamePageState();
}

class _GetUsernamePageState extends State<GetUsernamePage> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _checkUsernameExists(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _onContinueTap() async {
    final username = _usernameController.text.trim();

    if (username.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final usernameExists = await _checkUsernameExists(username);

      if (usernameExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Username already exists'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Save the username to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'username': username}, SetOptions(merge: true));

          // Navigate to YourInterestsPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => YourInterestsPage()),
          );
        } else {
          // Handle the case where no user is logged in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No user is logged in'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a username'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // New user logo
                Image.asset(
                  'lib/images/new_user_logo.png', // Replace with your new logo path
                  height: MediaQuery.of(context).size.height * 0.15,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // Enter username text
                const Text(
                  'Enter your username',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Username text field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Continue button
                ElevatedButton(
                  onPressed: _onContinueTap,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
