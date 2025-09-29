import 'package:flutter/material.dart';
import 'package:chakak_flutter/data/dtos/help_dto.dart';

class ContactCard extends StatelessWidget {
  final HelpDto dto;
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String? subtitle;
  final Color color;

  const ContactCard({
    super.key,
    required this.dto,
    this.icon,
    this.imagePath,
    required this.title,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 30, color: Colors.black87)
          else if (imagePath != null)
            Image.asset(imagePath!, width: 32, height: 32),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
