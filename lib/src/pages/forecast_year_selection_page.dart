import 'package:flutter/material.dart';
import 'weather_forecast_page.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/weather_service.dart';
import 'dart:math';

class ForecastYearSelectionPage extends StatefulWidget {
  const ForecastYearSelectionPage({Key? key}) : super(key: key);

  @override
  State<ForecastYearSelectionPage> createState() => _ForecastYearSelectionPageState();
}

class _ForecastYearSelectionPageState extends State<ForecastYearSelectionPage> {
  late Future<Map<String, dynamic>> _currentWeatherFuture;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
    // Show the info dialog after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogShown) {
        _showInfoDialog();
        _dialogShown = true;
      }
    });
  }

  Future<void> _initAndLoad() async {
    final weatherService = await WeatherService.init();
    setState(() {
      _currentWeatherFuture = weatherService.getCurrentWeather();
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('How to Use the Forecasts', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Click a year below to see the temperature forecast percentages for each month.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'The percentages show the chance that a month will be hotter, colder, or normal compared to usual.',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 10),
                Text(
                  'For example, if June shows "Above-normal: 70%", it means there is a 70% chance June will be hotter than usual.',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 16),
                Text(
                  'Why Are Some Months Missing?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Sometimes, not every month has a forecast. This is normal—forecasts are made for future months, and sometimes the data is missing or not available. Don't worry if you see gaps; it just means no forecast was made for that month.",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localization.translate('weather_forecast')),
            backgroundColor: const Color(0xFFA8D5BA),
            elevation: 0,
          ),
          backgroundColor: const Color(0xFFA8D5BA),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildWeatherHeroCard(),
                const SizedBox(height: 24),
                // Add a label above the years
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'Select a Year to View Forecasts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.left,
                  ),
                ),
                // Vertical list of large, rounded cards for each year (most recent at top)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _yearCard(context, 2025, isLatest: true),
                      SizedBox(height: 18),
                      _yearCard(context, 2024),
                      SizedBox(height: 18),
                      _yearCard(context, 2023),
                      SizedBox(height: 18),
                      _yearCard(context, 2022),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherHeroCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _currentWeatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text('🌧️', style: TextStyle(fontSize: 64)),
                    SizedBox(height: 12),
                    Text('Could not load current precipitation data.', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        }
        final data = snapshot.data!;
        final precipitation = (data['precipitation'] as num?)?.toDouble() ?? 0.0;
        final probability = (data['probability'] as num?)?.toDouble() ?? 1.0;
        String? dateStr;
        if (data['timestamp'] != null) {
          try {
            final dt = DateTime.tryParse(data['timestamp']);
            if (dt != null) {
              dateStr = 'Data for: ' + _formatDate(dt);
            }
          } catch (_) {}
        } else if (data['updated_at'] != null) {
          try {
            final dt = DateTime.tryParse(data['updated_at']);
            if (dt != null) {
              dateStr = 'Data for: ' + _formatDate(dt);
            }
          } catch (_) {}
        }
        // Coordinates and city
        String city = 'Tahcabo';
        double lat = 20.6537;
        double lon = -88.4460;
        if (data['location'] != null && data['location']['lat'] != null && data['location']['lon'] != null) {
          lat = (data['location']['lat'] as num).toDouble();
          lon = (data['location']['lon'] as num).toDouble();
        }
        String coordStr = 'Location: $city (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})';
        // Pick emoji based on precipitation and probability
        String emoji;
        if (precipitation >= 10 || probability >= 0.8) {
          emoji = '🌧️'; // Heavy rain
        } else if (precipitation > 0 && precipitation < 10 && probability >= 0.3) {
          emoji = '🌦️'; // Light rain
        } else if (precipitation == 0 && probability >= 0.3) {
          emoji = '⛅️'; // Cloudy/uncertain
        } else {
          emoji = '☀️'; // Sunny/very low chance
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 64)),
                  if (dateStr != null) ...[
                    const SizedBox(height: 4),
                    Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(coordStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWeatherInfo(Icons.water_drop, '${precipitation.toStringAsFixed(1)} mm', 'Precipitation'),
                      const SizedBox(width: 32),
                      _buildWeatherInfo(Icons.cloud, '${(probability * 100).toStringAsFixed(0)}%', 'Probability'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This is the most recent rainfall measurement for your area. The number shows how much rain fell recently, measured in millimeters (mm). Probability shows the chance of rain for today.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFA8D5BA), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _yearCard(BuildContext context, int year, {bool isLatest = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => YearlyForecastPage(year: year)),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: isLatest ? Color(0xFFDAB78D) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              year.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 