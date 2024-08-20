import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const SquareTile({
    super.key,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.pink, // Apply the pink color filter
            BlendMode.srcIn, // Use srcIn blend mode to apply the color
          ),
          child: Image.asset(
            imagePath,
            height: 40,
          ),
        ),
      ),
    );
  }
}