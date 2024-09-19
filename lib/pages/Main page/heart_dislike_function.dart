import 'package:flutter/material.dart';

Widget buildActionButtons({
  required void Function() onDislike,
  required void Function() onHeart,
  required void Function() onStar,
  bool isStarred = false,
  bool isHearted = false, // Add this parameter
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.close, Colors.orange, 60.0, onDislike),
        _buildActionButton(
          isHearted ? Icons.favorite : Icons.favorite_border, // Conditionally render the heart icon
          Colors.red,
          80.0,
          onHeart,
        ),
        _buildActionButton(
          isStarred ? Icons.star : Icons.star_border, // Conditionally render the star icon
          Colors.blue,
          60.0,
          onStar,
        ),
      ],
    ),
  );
}

Widget _buildActionButton(IconData icon, Color color, double size, void Function() onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    ),
  );
}
