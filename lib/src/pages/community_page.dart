import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';
import 'moon_phases_page.dart';
import 'forecast_year_selection_page.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({Key? key}) : super(key: key);

  void _navigateToWeather(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForecastYearSelectionPage()),
    );
  }

  void _navigateToMoonPhases(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoonPhasesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localization.translate('community_title')),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildCard(
                context,
                title: localization.translate('moon_phases'),
                icon: Icons.nightlight_round,
                onTap: () => _navigateToMoonPhases(context),
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: localization.translate('weather_forecast'),
                icon: Icons.cloud,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForecastYearSelectionPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: localization.translate('cultural_practices'),
                icon: Icons.people,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: localization.translate('environmental_conservation'),
                icon: Icons.eco,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: localization.translate('community_events'),
                icon: Icons.event,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                title: localization.translate('educational_resources'),
                icon: Icons.school,
                onTap: () {},
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
} 