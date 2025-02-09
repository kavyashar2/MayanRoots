import 'package:flutter/material.dart';
import 'maps_page.dart'; // Import the new maps page
import 'agricultural_cycles_page.dart'; // Import the new agriculture cycles page
import 'community_page.dart'; // Import the new community page
import 'menu_item.dart';
import 'reports_page.dart'; // Import the new reports page
import 'help_page.dart'; // Import the new help page
import 'settings_page.dart'; // Import the new settings page

void main() {
  runApp(LandingPage());
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preservando el Patrimonio de Yucatán'),
        backgroundColor: Color(0xFFCCEEFF),
        leading: Image.asset('assets/images/app_icon.png'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_icon.png', height: 100, width: 100),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the main menu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[200],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text('Empezar', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFCCEEFF),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú'),
        backgroundColor: Color(0xFFCCEEFF),
      ),
      body: ListView(
        children: [
          MenuItem(
            icon: Icons.map_outlined,
            title: 'Mapas',
            onPressed: () {
              // Navigate to the maps page
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapsPage()),
              );
            },
          ),
          MenuItem(
            icon: Icons.agriculture,
            title: 'Ciclos Agrícolas',
            onPressed: () {
              // Navigate to the agricultural cycles page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AgriculturalCyclesPage()),
              );
            },
          ),
          MenuItem(
            icon: Icons.group,
            title: 'Comunidad',
            onPressed: () {
              // Navigate to the community page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CommunityPage()),
              );
            },
          ),
          MenuItem(
            icon: Icons.report,
            title: 'Reportes',
            onPressed: () {
              // Navigate to the reports page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportsPage()),
              );
            },
          ),
          MenuItem(
            icon: Icons.help,
            title: 'Ayuda',
            onPressed: () {
              // Navigate to the help page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          ),
          MenuItem(
            icon: Icons.settings,
            title: 'Configuración',
            onPressed: () {
              // Navigate to the settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}