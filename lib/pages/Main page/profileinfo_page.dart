import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'matching_page.dart'; // Import the MatchingPage
import 'chat_page.dart'; // Import your ChatPage or adjust as necessary
import '../../services/auth_service.dart'; // Import the AuthService for logout
import '../Main page/custom_bottom_navbar.dart'; // Import your custom bottom nav bar
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfileInfoPage extends StatefulWidget {
  final String uid;

  const ProfileInfoPage({super.key, required this.uid});

  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  Map<String, dynamic>? profile;
  bool _isLoading = true;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchProfileByUid(widget.uid);
  }

  Future<void> _fetchProfileByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      final age = data?['birthday'] != null ? _calculateAge(data!['birthday']).toString() : 'Unknown';
      setState(() {
        profile = data;
        profile?['age'] = age;
        _isLoading = false;
      });
    }
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

  void _showEditAboutDialog() {
    final TextEditingController _aboutController = TextEditingController(text: profile?['about']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit About'),
          content: TextField(
            controller: _aboutController,
            decoration: const InputDecoration(hintText: 'Enter about info'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
                  'about': _aboutController.text,
                });
                setState(() {
                  profile?['about'] = _aboutController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _logout(); // Proceed with logout
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    AuthService().signout(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile Info',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // Toggle button icon
            onSelected: (value) {
              if (value == 'Edit') {
                _showEditAboutDialog();
              } else if (value == 'Logout') {
                _confirmLogout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitPumpingHeart(
                    color: Colors.purple, // Set the heart color to purple
                    size: 100.0, // Adjust size as needed
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(), // Optional loading progress bar
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        profile?['imageUrl'] ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username and Age
                  Center(
                    child: Text(
                      '${profile?['username'] ?? 'Unknown'}, ${profile?['age'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              name: profile?['username'] ?? 'Unknown',
                              image: profile?['imageUrl'] ?? 'https://via.placeholder.com/150',
                              currentUserId: currentUserId,
                              profileUserId: widget.uid,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Talk with your cou-pal',
                        style: TextStyle(fontSize: 16, color: Colors.blue), // Adjust color as needed
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // About Section
                  const Text(
                    'About:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile?['about'] ?? 'No information provided.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  // Interests Section
                  const Text(
                    'Interests:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  profile?['interests'] != null && profile!['interests'].isNotEmpty
                      ? Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: List<Widget>.generate(profile!['interests'].length, (int index) {
                            return Chip(
                              label: Text(profile!['interests'][index]),
                            );
                          }),
                        )
                      : const Text('No interests provided.'),
                  const SizedBox(height: 24),
                  // Gallery Section
                  const Text(
                    'Gallery:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Dummy images for gallery
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(6, (index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage('https://via.placeholder.com/150'), // Dummy image URL
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(
        selectedIndex: 3, // Set to Profile tab index
      ),
    );
  }
}
