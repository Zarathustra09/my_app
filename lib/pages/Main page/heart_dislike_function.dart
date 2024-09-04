import 'package:flutter/material.dart';

Widget buildActionButtons({
  required void Function() onDislike,
  required void Function() onHeart,
  required void Function() onStar,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.close, Colors.orange, 60.0, onDislike),
        _buildActionButton(Icons.favorite, Colors.red, 80.0, onHeart),
        _buildActionButton(Icons.star, Colors.blue, 60.0, onStar),
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
