// lib/pages/Main%20page/matches_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../components/toaster.dart';
import '../../services/matching_service.dart'; // Import the MatchingService
import 'messages_page.dart';
import 'matching_page.dart';
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
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    final fetchedMatches = await _matchingService.fetchStarredUsers();
    setState(() {
      _matches = fetchedMatches;
      _isLoading = false;
    });
  }

  Future<void> _deleteMatch(String starredUserId) async {
    await _matchingService.deleteStarredUser(starredUserId);
    _fetchMatches(); // Refresh the matches list
    Toaster.showToast("User removed from matches!");
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
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    match['image'] as String,
                    fit: BoxFit.cover,
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
                            onPressed: () {
                              // Handle like action
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0), // Highlight the "Matches" icon
    );
  }
}