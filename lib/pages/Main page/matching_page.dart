import 'package:flutter/material.dart';
import 'package:tcard/tcard.dart';
import '../../services/auth_service.dart';
import 'profileinfo_page.dart';
import 'messages_page.dart'; 
import 'matches_page.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  _MatchingPageState createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'CJ',
      'age': 22,
      'occupation': 'Professional model',
      'image': 'lib/images/ca.jpg'
    },
    {
      'name': 'Jarc diz',
      'age': 21,
      'occupation': 'Graphic Designer',
      'image': 'lib/images/Jar.jpg'
    },
    {
      'name': 'Heal Papi',
      'age': 22,
      'occupation': 'Photographer',
      'image': 'lib/images/he.jpg'
    },
  ];

  final TCardController _controller = TCardController();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MatchesPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MessagesPage()),
        );
        break;
      case 2:
        AuthService().signout(context: context);
        break;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,        
        title: Column(
          children: const [
            Text(
              'Discover',
              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Batangas, Philippines',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,        
      ),
      body: Center(
        child: TCard(
          cards: _profiles.map((profile) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileInfoPage(profile: profile),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey.withOpacity(0.5), spreadRadius: 5)],
                  image: DecorationImage(
                    image: AssetImage(profile['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile['name']}, ${profile['age']}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            profile['occupation'],
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          controller: _controller,
          onForward: (index, info) {
            if (info.direction == SwipDirection.Right) {
              // Handle swipe right action (like)
            } else if (info.direction == SwipDirection.Left) {
              // Handle swipe left action (dislike)
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[          
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.red),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
