import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'maps_page.dart'; // Import the new maps page
import 'agricultural_cycles_page.dart'; // Import the new agriculture cycles page
import 'community_page.dart'; // Import the new community page
import 'menu_item.dart';
import 'reports_page.dart'; // Import the new reports page
import 'help_page.dart'; // Import the new help page
import 'settings_page.dart'; // Import the new settings page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: LandingPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFCCEEFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preservando el',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Patrimonio de',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Yucatán',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Image.asset(
                  'assets/images/Chaac-light 1.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
              onPressed: () {
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
            ),
          ],
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('DEBUG: MenuPage build');
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
              print('DEBUG: Mapas menu item pressed');
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
              print('DEBUG: Ciclos Agrícolas menu item pressed');
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
              print('DEBUG: Comunidad menu item pressed');
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
              print('DEBUG: Reportes menu item pressed');
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
              print('DEBUG: Ayuda menu item pressed');
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
              print('DEBUG: Configuración menu item pressed');
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