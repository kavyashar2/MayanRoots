import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_forecast.dart';
import '../services/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class WeatherDisplayPage extends StatefulWidget {
  const WeatherDisplayPage({super.key});

  @override
  State<WeatherDisplayPage> createState() => _WeatherDisplayPageState();
}

class _WeatherDisplayPageState extends State<WeatherDisplayPage> {
  final _weatherService = WeatherService();
  WeatherForecast? _forecast;
  // Simulate data for the screenshot
  final String _currentLocation = "Tahcabo (20.6537, -88.4460)";
  final String _lastUpdated = "04/05/2025";
  final String _precipitationValue = "0.2 mm";
  final String _probabilityValue = "100%";

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final forecast = await _weatherService.getForecast(forceRefresh: forceRefresh);
      if (!mounted) return;
      
      setState(() {
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localization, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFA8D5BA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              localization.translate('weather_forecast_title'),
              style: const TextStyle(color: Colors.black),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: () => _loadForecast(forceRefresh: true),
              ),
            ],
          ),
          body: _buildBody(localization),
        );
      },
    );
  }

  Widget _buildBody(LocalizationService localization) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadForecast(forceRefresh: true),
              child: Text(localization.translate('try_again')),
            ),
          ],
        ),
      );
    }

    if (_forecast == null) {
      return Center(
        child: Text(localization.translate('no_forecast_available')),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadForecast(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeatherCard(localization),
            const SizedBox(height: 24),
            _buildHistoricalDataSection(localization),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(LocalizationService localization) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/images/rain_cloud.png', height: 60),
            const SizedBox(height: 16),
            Text('${localization.translate('location_label')}: $_currentLocation'),
            Text('${localization.translate('data_updated_label')}: $_lastUpdated'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(_precipitationValue, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(localization.translate('precipitation_label')),
                  ],
                ),
                Column(
                  children: [
                    Text(_probabilityValue, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(localization.translate('probability_label')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              localization.translate('forecast_description'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              localization.translate('data_source_label'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalDataSection(LocalizationService localization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          localization.translate('historical_data_prompt'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5CBA7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            localization.translate('current_year_label'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.teal[700])
      ],
    );
  }
} 