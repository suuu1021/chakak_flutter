import 'package:flutter/material.dart';
import 'package:chakak_flutter/data/dtos/help_dto.dart';

class ContactCard extends StatelessWidget {
  final HelpDto dto;
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String? subtitle;
  final Color color;       // 배경 색상 외부에서 전달받음

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
      height: 120,
      decoration: BoxDecoration(
        color: color, // 외부에서 전달된 색상 사용
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 36, color: Colors.black87)
          else if (imagePath != null)
            Image.asset(imagePath!, width: 40, height: 40),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
