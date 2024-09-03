import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'messages_page.dart';
import 'profileinfo_page.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String image;
  final String currentUserId;
  final String profileUserId;

  const ChatPage({
    Key? key,
    required this.name,
    required this.image,
    required this.currentUserId,
    required this.profileUserId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final now = DateTime.now();
      final philippineTime = now.toUtc().add(Duration(hours: 8)); // Convert to Philippine Time (PHT)

      final messageData = {
        'sender': widget.currentUserId,
        'receiver': widget.profileUserId,
        'content': _controller.text,
        'timestamp': Timestamp.fromDate(philippineTime),
        'participants': [widget.currentUserId, widget.profileUserId],
      };

      await FirebaseFirestore.instance.collection('messages').add(messageData);

      setState(() {
        _controller.clear();
      });
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileInfoPage(uid: widget.profileUserId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MessagesPage()),
            );
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.image),
            ),
            SizedBox(width: 10),
            Text(widget.name),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('participants', arrayContains: widget.currentUserId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['sender'] == widget.currentUserId && data['receiver'] == widget.profileUserId) ||
                      (data['sender'] == widget.profileUserId && data['receiver'] == widget.currentUserId);
                }).toList();

                List<List<Map<String, dynamic>>> groupedMessages = [];
                for (var message in messages) {
                  final messageData = message.data() as Map<String, dynamic>;
                  final timestamp = messageData['timestamp'] != null ? (messageData['timestamp'] as Timestamp).toDate() : DateTime.now();
                  if (groupedMessages.isEmpty || timestamp.difference((groupedMessages.last.last['timestamp'] as Timestamp).toDate()).inMinutes > 5) {
                    groupedMessages.add([messageData]);
                  } else {
                    groupedMessages.last.add(messageData);
                  }
                }

                return ListView.builder(
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    final group = groupedMessages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: group.map((message) {
                        final isSender = message['sender'] == widget.currentUserId;
                        final timestamp = message['timestamp'] != null ? (message['timestamp'] as Timestamp).toDate() : DateTime.now();
                        final formattedTime = DateFormat('hh:mm a').format(timestamp);
                        final showTimestamp = group.first == message;

                        return Column(
                          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isSender ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message['content'],
                                  style: TextStyle(color: isSender ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                            if (showTimestamp)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  formattedTime,
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}