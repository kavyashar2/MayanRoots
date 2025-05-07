import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class WeatherDebugPage extends StatefulWidget {
  const WeatherDebugPage({super.key});

  @override
  State<WeatherDebugPage> createState() => _WeatherDebugPageState();
}

class _WeatherDebugPageState extends State<WeatherDebugPage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  String _error = '';
  String _debugLog = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  void _addToLog(String message) {
    setState(() {
      _debugLog = '$message\n$_debugLog';
    });
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _debugLog = 'Starting new request...\n';
    });

    try {
      _addToLog('🔍 Starting network diagnostics...');
      final data = await _weatherService.getCurrentWeather();
      setState(() {
        _weatherData = data;
        _isLoading = false;
        _addToLog('✅ Weather data received successfully');
      });
    } catch (e) {
      String errorMessage = e.toString();
      
      // Format the error message for better readability
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      
      _addToLog('❌ Error occurred:');
      _addToLog(errorMessage);

      if (e is DioException) {
        _addToLog('Network error details:');
        _addToLog('Type: ${e.type}');
        _addToLog('Message: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadWeatherData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Network Error',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _loadWeatherData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Connection'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Text(
              'Debug Log:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _debugLog,
                style: const TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
            if (_weatherData != null) ...[
              const SizedBox(height: 16),
              Text(
                'Weather Data:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(_weatherData),
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 