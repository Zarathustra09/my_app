import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'matching_page.dart'; // Import the MatchingPage
import 'chat_page.dart'; // Import your ChatPage or adjust as necessary

class ProfileInfoPage extends StatefulWidget {
  final String uid;

  const ProfileInfoPage({super.key, required this.uid});

  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  Map<String, dynamic>? profile;
  bool _isLoading = true;

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
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
                    'about': _aboutController.text,
                  });
                  setState(() {
                    profile?['about'] = _aboutController.text;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MatchingPage()), // Redirect to MatchingPage
        );
        return false; // Prevent default back button action
      },
      child: Scaffold(
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
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      name: profile?['username'] ?? 'Unknown',
                      image: profile?['imageUrl'] ?? 'https://via.placeholder.com/150',
                      currentUserId: FirebaseAuth.instance.currentUser!.uid,
                      profileUserId: widget.uid,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/icons/LOGO.png', // Your app's logo path
                      height: 150, // Adjust height as needed
                    ),
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(), // Loading progress bar
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
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _showEditAboutDialog,
                        child: const Text('Edit About'),
                      ),
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
                  ],
                ),
              ),
      ),
    );
  }
}
