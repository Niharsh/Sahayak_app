import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  EmptyState({required this.title, required this.subtitle, this.icon = Icons.inbox});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: Colors.grey[400]),
        SizedBox(height: 12),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
      ]),
    );
  }
}
