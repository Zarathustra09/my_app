// lib/pages/Main%20page/matching_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _MatchingPageState extends State<MatchingPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;
  int _selectedIndex = 1;
  bool _isHearted = false;
  final MatchingService _matchingService = MatchingService();
  final int _pageSize = 10; // Number of profiles to load per page
  DocumentSnapshot? _lastDocument; // Last document snapshot for pagination
  Map<String, bool> _starredStatus = {}; // Cache starred status
  Map<String, bool> _heartedStatus = {}; // Cache hearted status
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveCurrentIndex();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _saveCurrentIndex();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastViewedProfileIndex();
  }

  Future<void> _saveCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPageIndex', _selectedIndex);
  }

  Future<void> _loadLastViewedProfileIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt('currentPageIndex') ?? 0;
    setState(() {
      _selectedIndex = lastIndex;
    });
    await _fetchProfiles();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchProfiles() async {
    final fetchedProfiles = await _matchingService.fetchProfiles(_pageSize, _lastDocument);
    for (var profile in fetchedProfiles) {
      _starredStatus[profile['uid']] = await _matchingService.isUserStarred(profile['uid']);
      _heartedStatus[profile['uid']] = await _matchingService.isUserHearted(profile['uid']);
    }
    setState(() {
      _profiles.addAll(fetchedProfiles);
      _isLoading = false;
    });
  }

  void _onHeart(String heartedUserId) async {
    final isHearted = await _matchingService.isUserHearted(heartedUserId);
    if (isHearted) {
      await _matchingService.deleteHeartedUser(heartedUserId);
      Toaster.showToast("User unhearted!");
      setState(() {
        _heartedStatus[heartedUserId] = false;
      });
    } else {
      await _matchingService.saveHeartedUser(heartedUserId);
      Toaster.showToast("User hearted!");
      setState(() {
        _heartedStatus[heartedUserId] = true;
      });
    }
  }

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
              'Find your Cou-Pal',
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
              controller: PageController(initialPage: _selectedIndex),
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
                final isHearted = _heartedStatus[profile['uid']] ?? false;
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
                    onHeart: () {
                      if (_profiles.isNotEmpty && _selectedIndex < _profiles.length) {
                        _onHeart(_profiles[_selectedIndex]['uid']);
                      } else {
                        Fluttertoast.showToast(msg: "No profile available");
                      }
                    },
                    onStar: () {
                      if (_profiles.isNotEmpty && _selectedIndex < _profiles.length) {
                        _onStar(_profiles[_selectedIndex]['uid']);
                      } else {
                        Fluttertoast.showToast(msg: "No profile available");
                      }
                    },
                    isStarred: _profiles.isNotEmpty && _selectedIndex < _profiles.length
                        ? _starredStatus[_profiles[_selectedIndex]['uid']] ?? false
                        : false,
                    isHearted: _profiles.isNotEmpty && _selectedIndex < _profiles.length
                        ? _heartedStatus[_profiles[_selectedIndex]['uid']] ?? false
                        : false,
                  ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}