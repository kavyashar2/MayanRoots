import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalWeatherService {
  static const String _currentWeatherKey = 'current_weather';
  static const String _forecastKey = 'weather_forecast';
  static const String _seasonalForecastKey = 'seasonal_forecast';
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  final SharedPreferences _prefs;
  
  LocalWeatherService._(this._prefs);
  
  static LocalWeatherService? _instance;
  
  static Future<LocalWeatherService> init() async {
    if (_instance != null) return _instance!;
    
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalWeatherService._(prefs);
    return _instance!;
  }
  
  Future<void> saveCurrentWeather(Map<String, dynamic> weather) async {
    final data = {
      'data': weather,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_currentWeatherKey, jsonEncode(data));
  }
  
  Future<Map<String, dynamic>?> getCurrentWeather() async {
    final jsonStr = _prefs.getString(_currentWeatherKey);
    if (jsonStr == null) return null;
    
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final timestamp = DateTime.parse(data['timestamp'] as String);
    
    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      await _prefs.remove(_currentWeatherKey);
      return null;
    }
    
    return data['data'] as Map<String, dynamic>;
  }
  
  Future<void> saveForecast(Map<String, dynamic> forecast) async {
    final data = {
      'data': forecast,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_forecastKey, jsonEncode(data));
  }
  
  Future<Map<String, dynamic>?> getForecast() async {
    final jsonStr = _prefs.getString(_forecastKey);
    if (jsonStr == null) return null;
    
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final timestamp = DateTime.parse(data['timestamp'] as String);
    
    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      await _prefs.remove(_forecastKey);
      return null;
    }
    
    return data['data'] as Map<String, dynamic>;
  }
  
  Future<void> saveSeasonalForecast(Map<String, dynamic> forecast) async {
    final data = {
      'data': forecast,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_seasonalForecastKey, jsonEncode(data));
  }
  
  Future<Map<String, dynamic>?> getSeasonalForecast() async {
    final jsonStr = _prefs.getString(_seasonalForecastKey);
    if (jsonStr == null) return null;
    
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final timestamp = DateTime.parse(data['timestamp'] as String);
    
    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      await _prefs.remove(_seasonalForecastKey);
      return null;
    }
    
    return data['data'] as Map<String, dynamic>;
  }
  
  Future<void> clearWeatherData() async {
    await _prefs.remove(_currentWeatherKey);
    await _prefs.remove(_forecastKey);
    await _prefs.remove(_seasonalForecastKey);
  }
} 