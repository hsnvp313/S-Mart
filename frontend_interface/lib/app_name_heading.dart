import 'package:flutter/material.dart';

class AppNameWithPage extends StatelessWidget {
  final String pageName;

  const AppNameWithPage({required this.pageName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            'S-mart',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            pageName.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
