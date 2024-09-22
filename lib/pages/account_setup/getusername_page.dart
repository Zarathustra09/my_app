import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'yourinterest_page.dart';

class GetUsernamePage extends StatefulWidget {
  const GetUsernamePage({super.key});

  @override
  _GetUsernamePageState createState() => _GetUsernamePageState();
}

class _GetUsernamePageState extends State<GetUsernamePage> {
  final _usernameController = TextEditingController();
  final _birthdayController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingUsername();
  }

  Future<void> _checkExistingUsername() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!['username'] != null) {
        // Redirect to YourInterestsPage if username data exists
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => YourInterestsPage()),
        );
      }
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance.ref().child('user_images/${user.uid}.jpg');
        await storageRef.putFile(image);
        return await storageRef.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  bool isValidAge(String birthday) {
    final birthDate = DateTime.parse(birthday);
    final currentDate = DateTime.now();
    final age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      return age > 18;
    }
    return age >= 18;
  }

  Future<void> _onContinueTap() async {
    final username = _usernameController.text.trim();
    final birthday = _birthdayController.text.trim();

    if (username.isNotEmpty && _imageFile != null) {
      if (!isValidAge(birthday)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You must be 18 years old or above'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final usernameExists = await _checkUsernameExists(username);

      if (usernameExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Username already exists'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final imageUrl = await _uploadImage(_imageFile!);

          if (imageUrl != null) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'username': username,
              'birthday': birthday,
              'imageUrl': imageUrl,
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => YourInterestsPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to upload image'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No user logged in'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a username, select a birthday, and upload an image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // Circular profile image with upload icon
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.purple,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // Enter username text
                const Text(
                  'Enter your username',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Username text field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Birthday text field with date picker
                TextField(
                  controller: _birthdayController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select your birthday',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Continue button
                ElevatedButton(
                  onPressed: _onContinueTap,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
