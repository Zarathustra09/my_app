import 'package:flutter/material.dart';
import '../Main page/matching_page.dart'; // Import the matching page

class EnableNotificationsPage extends StatelessWidget {
  const EnableNotificationsPage({super.key});

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
                const Spacer(flex: 2), // Add spacing at the top
                const Text(
                  'Enable notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Get push-notification when you get a match or receive a message.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3), // Add spacing between text and button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to MatchingPage when the button is pressed
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MatchingPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'I want to be notified',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(flex: 2), // Add spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
