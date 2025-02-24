import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF45A186)),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF45A186)),
        onTap: onPressed,
      ),
    );
  }
}
