import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeStatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const HomeStatItem({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.sawarabiGothic(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.sawarabiGothic(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
