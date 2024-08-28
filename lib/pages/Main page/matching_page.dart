import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final List<Map<String, dynamic>> fetchedProfiles = snapshot.docs.map((doc) {
        final data = doc.data();
        final birthday = data['birthday'] != null ? DateTime.parse(data['birthday']) : null;
        final age = birthday != null ? (DateTime.now().year - birthday.year).toString() : 'Unknown';
        return {
          'name': data['username'] ?? 'Unknown', // Default to 'Unknown' if null
          'age': age, // Age is already a string
          'image': data['imageUrl'] ?? 'https://via.placeholder.com/150', // Default to a placeholder image URL
          'interests': data['interests'] ?? [], // Default to an empty array if null
        };
      }).toList();

      setState(() {
        _profiles = fetchedProfiles;
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
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
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                MaterialPageRoute(builder: (context) => ProfileInfoPage(profile: profile)),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(profile['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Age: ${profile['age']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Wrap(
                          children: (profile['interests'] as List<dynamic>).map((interest) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(interest),
                                backgroundColor: Colors.pink,
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
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