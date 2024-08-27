import 'package:flutter/material.dart';
import 'matching_page.dart'; // Import the MatchingPage
import 'matches_page.dart'; // Import the MatchesPage

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

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
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Activities',
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActivityCircle(image: 'lib/images/ca.jpg', name: 'You'),
                  ActivityCircle(image: 'lib/images/ca.jpg', name: 'Emma'),
                  ActivityCircle(image: 'lib/images/he.jpg', name: 'Ava'),
                  ActivityCircle(image: 'lib/images/ca.jpg', name: 'Sophia'),
                  // Add more ActivityCircle widgets as needed
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Messages',
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  MessageTile(
                    image: 'lib/images/ca.jpg',
                    name: 'Emelie',
                    message: 'Sticker 😍',
                    time: '23 min',
                  ),
                  MessageTile(
                    image: 'lib/images/ca.jpg',
                    name: 'Abigail',
                    message: 'Typing...',
                    time: '27 min',
                  ),
                  MessageTile(
                    image: 'lib/images/ca.jpg',
                    name: 'Elizabeth',
                    message: 'Ok, see you then.',
                    time: '33 min',
                  ),
                  // Add more MessageTile widgets as needed
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: Colors.red),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Discover',
          ),
        ],
        currentIndex: 1, // Highlight the "Messages" icon
        selectedItemColor: Colors.red,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MatchesPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MatchingPage()),
            );
          }
          // The "Messages" button will remain highlighted and unclickable
        },
      ),
    );
  }
}

class ActivityCircle extends StatelessWidget {
  final String image;
  final String name;

  const ActivityCircle({
    Key? key,
    required this.image,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String image;
  final String name;
  final String message;
  final String time;

  const MessageTile({
    Key? key,
    required this.image,
    required this.name,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(image),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
