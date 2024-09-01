import 'package:flutter/material.dart';
import 'messages_page.dart';
import 'matching_page.dart';
import '../themes.dart';
import '../../services/auth_service.dart';
import 'custom_bottom_navbar.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = [
      {'name': 'Heal', 'age': 19, 'image': 'lib/images/he.jpg'},
      {'name': 'Carl', 'age': 20, 'image': 'lib/images/ca.jpg'},
      {'name': 'Jarc', 'age': 24, 'image': 'lib/images/ca.jpg'},
      // Add more matches here
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Matches',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    match['image'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match['name']}, ${match['age']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              // Handle dislike action
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.pink),
                            onPressed: () {
                              // Handle like action
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0), // Highlight the "Matches" icon
    );
  }
}
