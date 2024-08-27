import 'package:flutter/material.dart';
import 'messages_page.dart'; // Import the MessagesPage
import 'matching_page.dart'; // Import the MatchingPage

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
        title: const Text('Matches'),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.red),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Discover',
          ),
        ],
        currentIndex: 0, // Highlight the "Matches" icon
        selectedItemColor: Colors.red,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MessagesPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MatchingPage()),
            );
          }
          // The "Matches" button will remain highlighted and unclickable
        },
      ),
    );
  }
}
