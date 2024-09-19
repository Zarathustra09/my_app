// lib/pages/Main%20page/matches_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../components/toaster.dart';
import '../../services/matching_service.dart'; // Import the MatchingService
import 'messages_page.dart';
import 'matching_page.dart';
import 'chat_page.dart'; // Import ChatPage
import '../themes.dart';
import 'custom_bottom_navbar.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  final MatchingService _matchingService = MatchingService(); // Create an instance of MatchingService

  @override
  void initState() {
    super.initState();
    _loadCachedMatches();
  }

  Future<void> _loadCachedMatches() async {
    // Load cached matches if available
    final cachedMatches = await _matchingService.getCachedMatches();
    if (cachedMatches.isNotEmpty) {
      setState(() {
        _matches = cachedMatches;
        _isLoading = false;
      });
    } else {
      _fetchMatches();
    }
  }

  Future<void> _fetchMatches() async {
    final fetchedMatches = await _matchingService.fetchStarredUsers();
    setState(() {
      _matches = fetchedMatches;
      _isLoading = false;
    });
    // Cache the fetched matches
    await _matchingService.cacheMatches(fetchedMatches);
  }

  Future<void> _deleteMatch(String starredUserId) async {
    await _matchingService.deleteStarredUser(starredUserId);
    _fetchMatches(); // Refresh the matches list
    Toaster.showToast("User removed from matches!");
  }

  void _onLike(String profileUserId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(),
      ),
    );
  }

  void _onMatchTap(Map<String, dynamic> match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          name: match['name'],
          image: match['image'],
          currentUserId: FirebaseAuth.instance.currentUser!.uid,
          profileUserId: match['uid'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Matches',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return GestureDetector(
            onTap: () => _onMatchTap(match),
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: match['image'] as String,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${match['name']}, ${match['age']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _deleteMatch(match['uid']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.pink),
                              onPressed: () => _onLike(match['uid']),
                            ),
                          ],
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0), // Highlight the "Matches" icon
    );
  }
}