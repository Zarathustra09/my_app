import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/pages/account_setup/getusername_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'yourinterest_page.dart';
import '../background.dart'; // Import your background gradient file

class IamPage extends StatefulWidget {
  const IamPage({super.key});

  @override
  _IamPageState createState() => _IamPageState();
}

class _IamPageState extends State<IamPage> {
  String? _selectedGender;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingGender();
  }

  void _checkExistingGender() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!['gender'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GetUsernamePage()),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onGenderTap(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _onContinueTap() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _selectedGender != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'gender': _selectedGender}, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GetUsernamePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/icons/LOGO.png', // Your logo asset path
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20), // Spacing between the logo and progress bar
              const CircularProgressIndicator(), // Progress indicator below the logo
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'I am a',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildGenderTile('Woman'),
                const SizedBox(height: 10),
                _buildGenderTile('Man'),
                const SizedBox(height: 20),
                _buildGradientButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gender selection tile with gradient background when selected
  Widget _buildGenderTile(String gender) {
    final bool isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => _onGenderTap(gender),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: Background.gradientColors, // Gradient colors when selected
          )
              : null, // No gradient if not selected
          color: isSelected ? null : Colors.grey[200], // Light background if not selected
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(
            gender,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black, // White text when selected
            ),
          ),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      ),
    );
  }

  // Gradient button for Continue
  Widget _buildGradientButton() {
    return InkWell(
      onTap: _onContinueTap,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Background.gradientColors, // Gradient colors from background.dart
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
          child: const Center(
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}