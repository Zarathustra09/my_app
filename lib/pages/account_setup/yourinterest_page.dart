import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/pages/Main%20page/matching_page.dart';
import 'notification_pages.dart'; // Updated import to notification_pages.dart
import '../background.dart'; // Import the background gradient file
import 'package:flutter_spinkit/flutter_spinkit.dart';

class YourInterestsPage extends StatefulWidget {
  const YourInterestsPage({super.key});

  @override
  _YourInterestsPageState createState() => _YourInterestsPageState();
}

class _YourInterestsPageState extends State<YourInterestsPage> {
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Cosplay', 'icon': 'lib/icons/COSPLAY.png'},
    {'name': 'FPS', 'icon': 'lib/icons/FPS.png'},
    {'name': 'Moba', 'icon': 'lib/icons/MOBA.png'},
    {'name': 'Puzzle', 'icon': 'lib/icons/PUZZLE.png'},
    {'name': 'Horror', 'icon': 'lib/icons/GHOST.png'},
    {'name': 'RPG', 'icon': 'lib/icons/RPG.png'},
    {'name': 'Casual', 'icon': 'lib/icons/CASUAL.png'},
    {'name': 'Racing', 'icon': 'lib/icons/WHEEL.png'},
    {'name': 'Gacha', 'icon': 'lib/icons/GACHA.png'},
    {'name': 'Strategy', 'icon': ''}, // Add appropriate image path if available
  ];

  final Set<String> _selectedInterests = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingInterests();
  }

  void _checkExistingInterests() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!['interests'] != null && (doc.data()!['interests'] as List).isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MatchingPage()), // Updated to MatchingPage
        );
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onInterestTap(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _onContinueTap() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _selectedInterests.isNotEmpty) {
      // Save the selected interests to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'interests': _selectedInterests.toList()}, SetOptions(merge: true));

      // Navigate to NotificationPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EnableNotificationsPage()), // Updated to NotificationPage
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one interest'),
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
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(), // Add progress indicator
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
                  'Your interests',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Select a few of your interests and let everyone know what you\'re passionate about.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: _interests.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final interest = _interests[index];
                      final isSelected = _selectedInterests.contains(interest['name']);
                      return GestureDetector(
                        onTap: () => _onInterestTap(interest['name']),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: Background.gradientColors, // Gradient colors when selected
                                  )
                                : null,
                            color: isSelected ? null : Colors.grey[200], // Default color if not selected
                            border: Border.all(
                              color: isSelected ? Colors.pink : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              interest['icon'] != ''
                                  ? Image.asset(
                                      interest['icon'],
                                      width: 24,
                                      height: 24,
                                      color: isSelected ? Colors.white : Colors.black,
                                    )
                                  : Container(), // Handle missing icon case
                              const SizedBox(width: 8),
                              Text(
                                interest['name'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _onContinueTap,
                  style: ElevatedButton.styleFrom(
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
