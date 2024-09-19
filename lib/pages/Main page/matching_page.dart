// lib/pages/Main%20page/matching_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../components/toaster.dart';
import '../../services/auth_service.dart';
import '../../services/matching_service.dart';
import 'package:my_app/components/toaster.dart';
import 'profileinfo_page.dart';
import 'messages_page.dart';
import 'matches_page.dart';
import '../themes.dart';
import 'heart_dislike_function.dart';
import 'custom_bottom_navbar.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  _MatchingPageState createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;
  int _selectedIndex = 1;
  bool _isHearted = false;
  final MatchingService _matchingService = MatchingService();
  final int _pageSize = 10; // Number of profiles to load per page
  DocumentSnapshot? _lastDocument; // Last document snapshot for pagination
  Map<String, bool> _starredStatus = {}; // Cache starred status

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    final fetchedProfiles = await _matchingService.fetchProfiles(_pageSize, _lastDocument);
    for (var profile in fetchedProfiles) {
      _starredStatus[profile['uid']] = await _matchingService.isUserStarred(profile['uid']);
    }
    setState(() {
      _profiles.addAll(fetchedProfiles);
      _isLoading = false;
    });
  }

  void _onHeart(String likedUserId) {
    setState(() {
      _isHearted = !_isHearted;
    });
    if (_isHearted) {
      _matchingService.saveLikedUser(likedUserId);
      Toaster.showToast("User liked!");
    }
  }

  // lib/pages/Main%20page/matching_page.dart
// lib/pages/Main%20page/matching_page.dart

  void _onStar(String starredUserId) async {
    final isStarred = await _matchingService.isUserStarred(starredUserId);
    if (isStarred) {
      // Unstar the user
      await _matchingService.deleteStarredUser(starredUserId);
      Toaster.showToast("User unstarred!");
      setState(() {
        _profiles.removeWhere((profile) => profile['uid'] == starredUserId);
        _starredStatus[starredUserId] = false;
      });
      // Remove the unstarred user from the matches page
      await _matchingService.removeUserFromMatches(starredUserId);
    } else {
      // Star the user
      await _matchingService.saveStarredUser(starredUserId);
      Toaster.showToast("User starred!");
      final newStarredUser = await _matchingService.fetchUserById(starredUserId);
      setState(() {
        _profiles.add(newStarredUser);
        _starredStatus[starredUserId] = true;
      });
      // Add the starred user to the matches page
      await _matchingService.addUserToMatches(newStarredUser);
    }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: _profiles.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                if (index == _profiles.length - 1) {
                  _fetchProfiles(); // Load more profiles when reaching the end
                }
              },
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                final isStarred = _starredStatus[profile['uid']] ?? false;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileInfoPage(uid: profile['uid'])),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10,
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5),
                      ],
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(profile['image']),
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
                                '${profile['name']}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                profile['age'],
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
          ),
          buildActionButtons(
            onDislike: () {
              // Handle dislike action
            },
            onHeart: () => _onHeart(_profiles[_selectedIndex]['uid']),
            onStar: () => _onStar(_profiles[_selectedIndex]['uid']),
            isStarred: _starredStatus[_profiles[_selectedIndex]['uid']] ?? false, // Pass the starred status
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}