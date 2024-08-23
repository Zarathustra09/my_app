import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Main page/matching_page.dart';

class YourInterestsPage extends StatefulWidget {
  const YourInterestsPage({super.key});

  @override
  _YourInterestsPageState createState() => _YourInterestsPageState();
}

class _YourInterestsPageState extends State<YourInterestsPage> {
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Cosplay', 'icon': Icons.camera_alt},
    {'name': 'FPS', 'icon': Icons.shopping_bag},
    {'name': 'Moba', 'icon': Icons.mic},
    {'name': 'Puzzle', 'icon': Icons.self_improvement},
    {'name': 'Horror', 'icon': Icons.restaurant},
    {'name': 'RPG', 'icon': Icons.sports_tennis},
    {'name': 'Casual', 'icon': Icons.directions_run},
    {'name': 'Racing', 'icon': Icons.pool},
    {'name': 'MMO', 'icon': Icons.palette},
    {'name': 'Gacha', 'icon': Icons.flight},
    {'name': 'Strategy', 'icon': Icons.dangerous},
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
        // Redirect to MatchingPage if interests data exists
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MatchingPage()),
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

      // Navigate to MatchingPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MatchingPage()),
      );
    } else {
      // Handle the case where no interest is selected
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
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _onContinueTap,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
                            color: isSelected ? Colors.pink : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.pink : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                interest['icon'],
                                color: isSelected ? Colors.white : Colors.black,
                              ),
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
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.pink,
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
