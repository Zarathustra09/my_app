import 'package:flutter/material.dart';
import 'matches_page.dart';
import 'matching_page.dart';
import 'messages_page.dart';
import '../Main page/profileinfo_page.dart'; // Import ProfileInfoPage
import '../../services/auth_service.dart';
import '../themes.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for current user

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.navbarBackground,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Matches',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_search),
          label: 'Discover',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.textHighlight,
      unselectedItemColor: AppColors.iconUnselected,
      showUnselectedLabels: true,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MatchesPage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MatchingPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MessagesPage()),
            );
            break;
          case 3:
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileInfoPage(uid: currentUser.uid), // Navigate to ProfileInfoPage
                ),
              );
            }
            break;
        }
      },
    );
  }
}
