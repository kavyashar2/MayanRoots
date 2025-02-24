import 'package:flutter/material.dart';
import 'maps_page.dart';
import 'agricultural_cycles_page.dart';
import 'community_page.dart';
import 'menu_item.dart';
import 'reports_page.dart';
import 'help_page.dart';
import 'settings_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú', style: TextStyle(color: Color(0xFFFFFFFF))),
        backgroundColor: Color(0xFF45A186),
      ),
      body: ListView(
        children: [
          MenuItem(
            icon: Icons.map_outlined,
            title: 'Mapas',
            onPressed: () {
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