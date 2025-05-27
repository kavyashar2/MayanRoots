import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';
import 'moon_phases_page.dart';
import 'forecast_year_selection_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scrollController = ScrollController();

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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFA8D5BA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Icon(Icons.groups, color: Color(0xFF217055), size: 34),
                    const SizedBox(width: 10),
                    Text(
                      localization.translate('community_title'),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              ListView(
                controller: _scrollController,
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
                ],
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
    // Simple approach: just look for emojis at the end of the string
    String displayTitle = title;
    String emoji = '';
    
    // Look for common emoji patterns at the end of the string
    if (title.endsWith('🌙') || title.endsWith('📊') || title.endsWith('🌦️')) {
      // Get the last character (emoji)
      emoji = title.substring(title.length - 2);
      // Remove emoji from display title
      displayTitle = title.substring(0, title.length - 2).trim();
    }
    
    return Card(
      color: const Color(0xFFF6E7C1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        leading: Text(
          emoji.isNotEmpty ? emoji : '📋', // Default emoji if none found
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          displayTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 24),
        onTap: onTap,
      ),
    );
  }
} 