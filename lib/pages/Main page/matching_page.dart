import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'profileinfo_page.dart';
import 'messages_page.dart';
import 'matches_page.dart';
import '../themes.dart'; 

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


  int _calculateAge(String birthday) {
    DateTime birthDate = DateTime.parse(birthday);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int _calculateMatchScore(List<dynamic> userInterests, List<dynamic> profileInterests) {
    int score = 0;
    for (var interest in userInterests) {
      if (profileInterests.contains(interest)) {
        score++;
      }
    }
    return score;
  }

// Update _fetchProfiles method in MatchingPage
  Future<void> _fetchProfiles() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userInterests = userDoc.data()?['interests'] ?? [];

      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final List<Map<String, dynamic>> fetchedProfiles = snapshot.docs.map((doc) {
        final data = doc.data();
        final age = data['birthday'] != null ? _calculateAge(data['birthday']).toString() : 'Unknown';
        final matchScore = _calculateMatchScore(userInterests, data['interests'] ?? []);
        return {
          'name': data['username'] ?? 'Unknown',
          'age': age,
          'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
          'interests': data['interests'] ?? [],
          'about': data['about'] ?? 'No information',
          'uid': doc.id,
          'matchScore': matchScore,
        };
      }).toList();

      // Sort profiles by matchScore in descending order
      fetchedProfiles.sort((a, b) => b['matchScore'].compareTo(a['matchScore']));

      // Print the fetched profiles
      print('Fetched Profiles: $fetchedProfiles');

      setState(() {
        _profiles = fetchedProfiles;
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _showLogoutConfirmation();
    } else if (index != 1) { // Prevent action for Discover button
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
        case 2:
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: const [
            Text(
              'Discover',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
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
                MaterialPageRoute(builder: (context) => ProfileInfoPage(uid: profile['uid'])),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5),
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
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          profile['occupation'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
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
        backgroundColor: AppColors.navbarBackground,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.textHighlight,
        unselectedItemColor: AppColors.iconUnselected,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
