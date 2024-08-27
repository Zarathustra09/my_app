import 'package:flutter/material.dart';
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
      'image': 'lib/images/ca.jpg',
    },
    {
      'name': 'Jarc diz',
      'age': 21,
      'occupation': 'Graphic Designer',
      'image': 'lib/images/ca.jpg',
    },
    {
      'name': 'Heal Papi',
      'age': 22,
      'occupation': 'Photographer',
      'image': 'lib/images/he.jpg',
    },
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      // Show a confirmation dialog when logout is tapped
      _showLogoutConfirmation();
    } else {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MatchesPage()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MessagesPage()),
          );
          break;
      }
    }
  }

  void _logout() {
    AuthService().signout(context: context);
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog before logging out
                _logout(); // Call the logout function
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
        automaticallyImplyLeading: false, // This line removes the back arrow
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
      body: PageView.builder(
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
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
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(blurRadius: 10, color: Colors.grey.withOpacity(0.5), spreadRadius: 5),
                ],
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
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
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
