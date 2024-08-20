import 'package:flutter/material.dart';
import 'yourinterest_page.dart';

class IamPage extends StatefulWidget {
  const IamPage({super.key});

  @override
  _IamPageState createState() => _IamPageState();
}

class _IamPageState extends State<IamPage> {
  String? _selectedGender;

  void _onContinueTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => YourInterestsPage()),
    );
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
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'I am a',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Woman'),
                  trailing: _selectedGender == 'Woman'
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  selected: _selectedGender == 'Woman',
                  selectedTileColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Woman';
                    });
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text('Man'),
                  trailing: _selectedGender == 'Man'
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  selected: _selectedGender == 'Man',
                  selectedTileColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Man';
                    });
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text('Choose another'),
                  trailing: const Icon(Icons.arrow_forward),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    // Handle choose another action
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _onContinueTap,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
