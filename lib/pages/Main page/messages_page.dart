import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/message_service.dart';
import 'chat_page.dart';
import 'custom_bottom_navbar.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final MessageService _messageService = MessageService();
  List<Map<String, dynamic>> _chatParticipants = [];
  List<Map<String, dynamic>> _filteredChatParticipants = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChatParticipants();
    _searchController.addListener(_filterChatParticipants);
  }

  Future<void> _fetchChatParticipants() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null) {
      final participants = await _messageService.getChatParticipants(
          currentUserUid);
      for (var participant in participants) {
        final profileUserId = participant['sender'] == currentUserUid
            ? participant['receiver']
            : participant['sender'];
        final userDoc = await FirebaseFirestore.instance.collection('users')
            .doc(profileUserId)
            .get();
        participant['imageUrl'] =
            userDoc.data()?['imageUrl'] ?? 'https://via.placeholder.com/150';
        participant['username'] = userDoc.data()?['username'] ?? 'Unknown';
      }
      setState(() {
        _chatParticipants = participants;
        _filteredChatParticipants = participants;
        _isLoading = false;
      });
    }
  }

  void _filterChatParticipants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChatParticipants = _chatParticipants;
      } else {
        _filteredChatParticipants = _chatParticipants.where((participant) {
          final username = participant['username']?.toLowerCase() ?? '';
          return username.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // More options
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search messages...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: SpinKitPumpingHeart(color: Theme
          .of(context)
          .primaryColor))
          : _filteredChatParticipants.isEmpty
          ? Center(
        child: Text(
          'Talk to your Cou-Pal now',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: _filteredChatParticipants.length,
          itemBuilder: (context, index) {
            final participant = _filteredChatParticipants[index];
            final profileUserId = participant['sender'] ==
                FirebaseAuth.instance.currentUser?.uid
                ? participant['receiver']
                : participant['sender'];
            return MessageTile(
              imageUrl: participant['imageUrl'] ??
                  'https://via.placeholder.com/150',
              name: participant['username'] ?? 'Unknown',
              message: participant['content'] ?? 'No message',
              time: participant['timestamp'] != null ? participant['timestamp']
                  .toDate()
                  .toString() : DateTime.now().toString(),
              currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
              profileUserId: profileUserId,
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String message;
  final String time;
  final String currentUserId;
  final String profileUserId;

  const MessageTile({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.message,
    required this.time,
    required this.currentUserId,
    required this.profileUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150'),
      ),
      title: Text(
        name.isNotEmpty ? name : 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message.isNotEmpty ? message : 'No message',
      ),
      trailing: Text(
        timeago.format(DateTime.parse(time.isNotEmpty ? time : DateTime.now().toString())),
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: name,
              image: imageUrl,
              currentUserId: currentUserId,
              profileUserId: profileUserId,
            ),
          ),
        );
      },
    );
  }
}
