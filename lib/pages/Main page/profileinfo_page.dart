import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profile?['imageUrl'] ?? 'https://via.placeholder.com/150'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${profile?['username'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  profile?['age'] ?? 'Unknown',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (currentUserUid == widget.uid)
                    GestureDetector(
                      onTap: _showEditAboutDialog,
                      child: const Icon(Icons.edit, color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                profile?['about'] ?? 'Emptiness is in here',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              const Text(
                'Interests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (profile?['interests'] ?? []).map<Widget>((interest) {
                  return Chip(
                    label: Text(interest),
                    backgroundColor: Colors.pink.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gallery',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildGalleryItem('lib/images/ca.jpg'),
                    _buildGalleryItem('lib/images/logo.png'),
                    _buildGalleryItem('lib/images/Jar.jpg'),
                    _buildGalleryItem('lib/images/he.jpg'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  'See all',
                  style: TextStyle(fontSize: 16, color: Colors.pink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: 80,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}