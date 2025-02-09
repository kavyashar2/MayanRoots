import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({super.key, required String title, required IconData icon, required Null Function() onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Item'),
      ),
      body: Center(
        child: Text('Menu Item'),
      ),
    );
  }
} // TODO Implement this library.