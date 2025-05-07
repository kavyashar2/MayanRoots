import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseWeatherService {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  static const String _weatherCollection = 'weatherForecasts';
  static const Duration _cacheExpiration = Duration(hours: 6);
  
  FirebaseWeatherService._({
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
  })  : _firestore = firestore,
        _analytics = analytics;

  static FirebaseWeatherService? _instance;
  
  static Future<FirebaseWeatherService> init() async {
    if (_instance != null) {
      print('✅ Reusing existing FirebaseWeatherService instance');
      return _instance!;
    }
    
    try {
      // Wait a bit to ensure main Firebase initialization is complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Use existing Firebase instances
      if (Firebase.apps.isEmpty) {
        throw StateError('Firebase not initialized. Please initialize Firebase before FirebaseWeatherService.');
      }
      
      final firestore = FirebaseFirestore.instance;
      final analytics = FirebaseAnalytics.instance;
      
      print('✅ Created new FirebaseWeatherService instance');
      _instance = FirebaseWeatherService._(
        firestore: firestore,
        analytics: analytics,
      );
      return _instance!;
    } catch (e) {
      print('❌ Error initializing FirebaseWeatherService: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> getShortTermForecast() async {
    try {
      final doc = await _firestore
          .collection('forecast_results')
          .doc('latest')
          .get();

      if (!doc.exists) {
        await _analytics.logEvent(
          name: 'forecast_error',
          parameters: {'error': 'document_not_found'}
        );
        return null;
      }

      final data = doc.data()!;
      if (data['status'] == 'error') {
        throw FirebaseException(
          plugin: 'weather',
          message: data['error'] ?? 'Unknown forecast error'
        );
      }

      await _analytics.logEvent(
        name: 'forecast_fetch',
        parameters: {'source': 'firebase'}
      );
      
      return data['data'] as Map<String, dynamic>;
    } catch (e) {
      await _analytics.logEvent(
        name: 'forecast_error',
        parameters: {'error': e.toString()}
      );
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getLongTermForecast() async {
    try {
      final doc = await _firestore
          .collection('forecast_results')
          .doc('seasonal')
          .get();

      if (!doc.exists) {
        await _analytics.logEvent(
          name: 'seasonal_error',
          parameters: {'error': 'document_not_found'}
        );
        return null;
      }

      final data = doc.data()!;
      if (data['status'] == 'error') {
        throw FirebaseException(
          plugin: 'weather',
          message: data['error'] ?? 'Unknown seasonal forecast error'
        );
      }

      await _analytics.logEvent(
        name: 'seasonal_fetch',
        parameters: {'source': 'firebase'}
      );
      
      return data['data'] as Map<String, dynamic>;
    } catch (e) {
      await _analytics.logEvent(
        name: 'seasonal_error',
        parameters: {'error': e.toString()}
      );
      return null;
    }
  }
  
  Stream<Map<String, dynamic>?> watchShortTermForecast() {
    return _firestore
        .collection(_weatherCollection)
        .doc('shortTermForecast')
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>?);
  }
  
  Stream<Map<String, dynamic>?> watchLongTermForecast() {
    return _firestore
        .collection(_weatherCollection)
        .doc('longTermForecast')
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>?);
  }
  
  Future<void> cacheLocally(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
  }
  
  Future<Map<String, dynamic>?> getLocalCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(key);
    if (cached != null) {
      return json.decode(cached) as Map<String, dynamic>;
    }
    return null;
  }
} 