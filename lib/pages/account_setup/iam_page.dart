import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/pages/account_setup/getusername_page.dart';
import 'yourinterest_page.dart';

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
        // Redirect to YourInterestsPage if gender data exists
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
      // Save the selected gender to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'gender': _selectedGender}, SetOptions(merge: true));

      // Navigate to YourInterestsPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => YourInterestsPage()),
      );
    } else {
      // Handle the case where no gender is selected
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
          child: CircularProgressIndicator(),
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
                ListTile(
                  title: const Text('Woman'),
                  trailing: _selectedGender == 'Woman'
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  selected: _selectedGender == 'Woman',
                  selectedTileColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () => _onGenderTap('Woman'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text('Man'),
                  trailing: _selectedGender == 'Man'
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  selected: _selectedGender == 'Man',
                  selectedTileColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () => _onGenderTap('Man'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text('Choose another'),
                  trailing: const Icon(Icons.arrow_forward),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    // Handle choose another action
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _onContinueTap,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
