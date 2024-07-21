import 'package:flutter/material.dart';

class ProfileInfoPage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfileInfoPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile Info',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(profile['image']),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${profile['name']}, ${profile['age']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  profile['occupation'],
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.pink),
                  const SizedBox(width: 4),
                  Text(
                    'Tanauan, Batangas, Philippines',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.favorite, color: Colors.pink),
                  const SizedBox(width: 4),
                  Text(
                    '1 km',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'About',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'My name is ${profile['name']} and I enjoy meeting new people and finding ways to help them have an uplifting experience. I enjoy reading...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Read more',
                style: TextStyle(fontSize: 16, color: Colors.pink),
              ),
              const SizedBox(height: 16),
              Text(
                'Interests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text('Traveling'),
                    backgroundColor: Colors.pink.withOpacity(0.2),
                  ),
                  Chip(
                    label: Text('Books'),
                    backgroundColor: Colors.pink.withOpacity(0.2),
                  ),
                  Chip(
                    label: Text('Music'),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                  Chip(
                    label: Text('Dancing'),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                  Chip(
                    label: Text('Modeling'),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Gallery',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildGalleryItem('lib/images/ca.jpg'),
                    _buildGalleryItem('lib/images/logo.png'),
                    _buildGalleryItem('lib/images/Jar.jpg'),
                    _buildGalleryItem('lib/images/he.jpg'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'See all',
                  style: TextStyle(fontSize: 16, color: Colors.pink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: 80,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
