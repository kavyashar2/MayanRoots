import 'package:flutter/material.dart';
import 'weather_forecast_page.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/weather_service.dart';
import 'dart:math';
import '../widgets/scroll_down_indicator.dart';

class ForecastYearSelectionPage extends StatefulWidget {
  const ForecastYearSelectionPage({Key? key}) : super(key: key);

  @override
  State<ForecastYearSelectionPage> createState() => _ForecastYearSelectionPageState();
}

class _ForecastYearSelectionPageState extends State<ForecastYearSelectionPage> {
  late Future<Map<String, dynamic>> _currentWeatherFuture = Future.value({});
  bool _dialogShown = false;
  final ScrollController _scrollController = ScrollController();
  int? _hoveredYear;

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
    final localization = Provider.of<LocalizationService>(context, listen: false); // Get localization instance
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(localization.translate('forecast_info_title'), style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.translate('forecast_info_instruction'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  localization.translate('forecast_info_explanation1'),
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 10),
                Text(
                  localization.translate('forecast_info_explanation2'),
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 16),
                Text(
                  localization.translate('forecast_info_q_missing_months'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  localization.translate('forecast_info_a_missing_months'),
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localization.translate('understood')), // Reusing existing 'understood' key
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
                    const SizedBox(width: 8),
                    Icon(Icons.cloud, color: Color(0xFF217055), size: 34),
                    const SizedBox(width: 10),
                    Text(
                      localization.translate('weather_forecast_title'),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFA8D5BA),
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildWeatherHeroCard(localization),
                    const SizedBox(height: 24),
                    // Add a label above the years
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        localization.translate('select_year'),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    // Vertical list of large, rounded cards for each year (most recent at top)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _yearCard(context, 2024, isLatest: true),
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
              ScrollDownIndicator(controller: _scrollController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherHeroCard(LocalizationService localization) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _currentWeatherFuture,
      builder: (context, snapshot) {
        print('DEBUG: FutureBuilder state: ${snapshot.connectionState}, hasError: ${snapshot.hasError}, data: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          print('DEBUG: Weather data error or empty. Error: ${snapshot.error}');
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
                    Text(
                      '${localization.translate('loading_error')}\n${localization.translate('connection_error')}', 
                      style: TextStyle(fontSize: 16), 
                      textAlign: TextAlign.center
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentWeatherFuture = WeatherService().getCurrentWeather();
                        });
                      },
                      child: Text(localization.translate('retry')),
                    ),
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
              dateStr = _formatDateDisplay(dt);
            }
          } catch (_) {}
        } else if (data['updated_at'] != null) {
          try {
            final dt = DateTime.tryParse(data['updated_at']);
            if (dt != null) {
              dateStr = _formatDateDisplay(dt);
            }
          } catch (_) {}
        }
        // Location info
        String city = 'Tahcabo';
        double lat = 20.6537;
        double lon = -88.4460;
        if (data['location'] != null && data['location']['lat'] != null && data['location']['lon'] != null) {
          lat = (data['location']['lat'] as num).toDouble();
          lon = (data['location']['lon'] as num).toDouble();
        }
        String coordStr = '${localization.translate('location')}: $city (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})';
        String dateLine = dateStr != null ? '${localization.translate('updated_data')}: $dateStr' : '';
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
                  const SizedBox(height: 4),
                  Text(coordStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  if (dateLine.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(dateLine, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWeatherInfo(Icons.water_drop, '${precipitation.toStringAsFixed(1)} mm', localization.translate('precipitation')),
                      const SizedBox(width: 32),
                      _buildWeatherInfo(Icons.cloud, '${(probability * 100).toStringAsFixed(0)}%', localization.translate('probability')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localization.translate('recent_rainfall_measurement'),
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${localization.translate('data_source')}: CHIRPS (Climate Hazards Group InfraRed Precipitation with Station data).',
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
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

  String _formatDateDisplay(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
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
    final bool isHovered = _hoveredYear == year;
    final Color orange = const Color(0xFFD6B48F);
    final Color cardColor = isLatest || isHovered ? orange : Colors.white;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredYear = year),
      onExit: (_) => setState(() => _hoveredYear = null),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hoveredYear = year),
        onTapUp: (_) => setState(() => _hoveredYear = null),
        onTapCancel: () => setState(() => _hoveredYear = null),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => YearlyForecastPage(year: year)),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: cardColor,
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
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 