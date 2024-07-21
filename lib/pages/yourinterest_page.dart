import 'package:flutter/material.dart';
import 'matching_page.dart';

class YourInterestsPage extends StatefulWidget {
  const YourInterestsPage({super.key});

  @override
  _YourInterestsPageState createState() => _YourInterestsPageState();
}

class _YourInterestsPageState extends State<YourInterestsPage> {
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Photography', 'icon': Icons.camera_alt},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Karaoke', 'icon': Icons.mic},
    {'name': 'Yoga', 'icon': Icons.self_improvement},
    {'name': 'Cooking', 'icon': Icons.restaurant},
    {'name': 'Tennis', 'icon': Icons.sports_tennis},
    {'name': 'Run', 'icon': Icons.directions_run},
    {'name': 'Swimming', 'icon': Icons.pool},
    {'name': 'Art', 'icon': Icons.palette},
    {'name': 'Traveling', 'icon': Icons.flight},
    {'name': 'Extreme', 'icon': Icons.dangerous},
    {'name': 'Music', 'icon': Icons.music_note},
    {'name': 'Drink', 'icon': Icons.local_bar},
    {'name': 'Video games', 'icon': Icons.videogame_asset},
  ];

  final Set<String> _selectedInterests = {};

  void _onInterestTap(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _onContinueTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatchingPage()),
    );
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
                    onPressed: () {},
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
