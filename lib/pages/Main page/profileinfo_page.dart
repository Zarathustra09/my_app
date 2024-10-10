import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'matching_page.dart';
import 'chat_page.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../Main page/custom_bottom_navbar.dart';
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
  final ProfileService _profileService = ProfileService();
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Cosplay', 'icon': 'lib/icons/COSPLAY.png'},
    {'name': 'FPS', 'icon': 'lib/icons/FPS.png'},
    {'name': 'Moba', 'icon': 'lib/icons/MOBA.png'},
    {'name': 'Puzzle', 'icon': 'lib/icons/PUZZLE.png'},
    {'name': 'Horror', 'icon': 'lib/icons/GHOST.png'},
    {'name': 'RPG', 'icon': 'lib/icons/RPG.png'},
    {'name': 'Casual', 'icon': 'lib/icons/CASUAL.png'},
    {'name': 'Racing', 'icon': 'lib/icons/WHEEL.png'},
    // Add more interests as needed
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfileByUid(widget.uid);
  }

  Future<void> _fetchProfileByUid(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      final age = data?['birthday'] != null ? _calculateAge(data!['birthday'])
          .toString() : 'Unknown';
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
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _addImage() async {
    if (currentUserId != widget.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You can only add images to your own profile.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (profile?['gallery'] != null && profile!['gallery'].length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You can only save up to 6 images.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final String imageUrl = await _profileService.uploadImage(
          imageFile, widget.uid);

      if (imageUrl.isNotEmpty) {
        await _profileService.addImageToGallery(widget.uid, imageUrl);

        setState(() {
          profile?['gallery'] = [...(profile?['gallery'] ?? []), imageUrl];
        });
      }
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    if (currentUserId != widget.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'You can only delete images from your own profile.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _profileService.deleteImageFromGallery(widget.uid, imageUrl);

    setState(() {
      profile?['gallery'] =
          profile?['gallery']?.where((url) => url != imageUrl).toList();
    });
  }

  void _showEditAboutDialog() {
    final TextEditingController _aboutController = TextEditingController(
        text: profile?['about']);

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
                await FirebaseFirestore.instance.collection('users').doc(
                    widget.uid).update({
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

  void _showEditInterestsDialog() {
    final Set<String> _tempSelectedInterests = Set.from(
        profile?['interests'] ?? []);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Interests'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _interests.map((interest) {
                    return CheckboxListTile(
                      title: Text(interest['name']),
                      value: _tempSelectedInterests.contains(interest['name']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _tempSelectedInterests.add(interest['name']);
                          } else {
                            _tempSelectedInterests.remove(interest['name']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
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
                    await FirebaseFirestore.instance.collection('users').doc(
                        widget.uid).update({
                      'interests': _tempSelectedInterests.toList(),
                    });
                    setState(() {
                      profile?['interests'] = _tempSelectedInterests.toList();
                    });
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileInfoPage(uid: widget.uid),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
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
          if (currentUserId == widget.uid)
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              onSelected: (value) {
                if (value == 'Logout') {
                  _confirmLogout();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
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
              color: Colors.purple,
              size: 100.0,
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  profile?['imageUrl'] ?? 'https://via.placeholder.com/150',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${profile?['username'] ?? 'Unknown'}, ${profile?['age'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (currentUserId == widget.uid)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: _showEditUsernameDialog,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (currentUserId != widget.uid)
              Center(
                child: TextButton.icon(
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
                  icon: const Icon(Icons.message, color: Colors.blue),
                  label: const Text(
                    'Talk with your Cou-Pal',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'About:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (currentUserId == widget.uid)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: _showEditAboutDialog,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              profile?['about'] ?? 'No information provided.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Interests:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (currentUserId == widget.uid)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: _showEditInterestsDialog,
                  ),
              ],
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
            const Text(
              'Gallery:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (profile?['gallery'] != null)
                  ...List.generate(profile!['gallery'].length, (index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImagePage(
                                  imageUrl: profile!['gallery'][index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(profile!['gallery'][index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        if (currentUserId == widget.uid)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteImage(profile!['gallery'][index]),
                            ),
                          ),
                      ],
                    );
                  }),
                if (currentUserId == widget.uid)
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: const Center(
                        child: Icon(Icons.add, size: 50, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        selectedIndex: 3,
      ),
    );
  }

  void _showEditUsernameDialog() {
    final TextEditingController _usernameController = TextEditingController(text: profile?['username']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(hintText: 'Enter new username'),
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
                  'username': _usernameController.text,
                });
                setState(() {
                  profile?['username'] = _usernameController.text;
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
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}