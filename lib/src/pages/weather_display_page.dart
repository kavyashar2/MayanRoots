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
              localization.translate('weather_forecast'),
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
            _buildShortTermForecast(localization),
            const SizedBox(height: 24),
            _buildLongTermForecast(localization),
            const SizedBox(height: 16),
            _buildLastUpdated(localization),
          ],
        ),
      ),
    );
  }

  Widget _buildShortTermForecast(LocalizationService localization) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.translate('short_term_forecast'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.translate('precipitation'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${_forecast!.shortTerm.precipMm.toStringAsFixed(1)} mm',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      localization.translate('confidence'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${(_forecast!.shortTerm.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLongTermForecast(LocalizationService localization) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.translate('seasonal_forecast'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProbabilityBar(
              label: localization.translate('wet'),
              probability: _forecast!.longTerm.wetProbability,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildProbabilityBar(
              label: localization.translate('normal'),
              probability: _forecast!.longTerm.normalProbability,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _buildProbabilityBar(
              label: localization.translate('dry'),
              probability: _forecast!.longTerm.dryProbability,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityBar({
    required String label,
    required double probability,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: probability,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 20,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${(probability * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastUpdated(LocalizationService localization) {
    final formatter = DateFormat.yMd().add_Hm();
    return Text(
      '${localization.translate('last_updated')}: ${formatter.format(_forecast!.updatedAt)}',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    );
  }
} 