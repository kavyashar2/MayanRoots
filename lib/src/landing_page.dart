import 'package:flutter/material.dart';
import 'menu_page.dart'; // Import the menu page

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF45A186),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_icon.png', height: 100, width: 100),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Empezar',
                style: TextStyle(fontSize: 20, color: Color(0xFF6CC48F)),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF45A186),
    );
  }
}
