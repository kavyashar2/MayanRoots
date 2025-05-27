import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'local_weather_service.dart';
import 'firebase_weather_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/weather_forecast.dart';
import 'dart:math';
import 'dart:async' show TimeoutException, StreamTransformer, EventSink;

class WeatherService {
  // Default location (Yucatán, Mexico)
  static const double _defaultLat = 20.6537;
  static const double _defaultLon = -88.4460;
  static const Duration _cacheExpiration = Duration(hours: 6);
  static const int _maxRetries = 3;
  static const Duration _emulatorStartupDelay = Duration(seconds: 10);
  
  final LocalWeatherService _localWeather;
  final FirebaseWeatherService _firebaseWeather;
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  bool _isInitialized = false;
  bool _isEmulator = false;
  
  WeatherService._({
    required LocalWeatherService localWeatherService,
    required FirebaseWeatherService firebaseWeatherService,
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
  })  : _localWeather = localWeatherService,
        _firebaseWeather = firebaseWeatherService,
        _firestore = firestore,
        _analytics = analytics;

  static WeatherService? _instance;
  factory WeatherService() {
    if (_instance == null) {
      throw StateError('WeatherService must be initialized via init()');
    }
    return _instance!;
  }

  static Future<WeatherService> init() async {
    if (_instance != null) {
      await _instance!._analytics.logEvent(
        name: 'weather_service_init',
        parameters: {'status': 'reused'}
      );
      return _instance!;
    }
    
    try {
      // Get Firebase instances - they should already be initialized
      final analytics = FirebaseAnalytics.instance;
      final firestore = FirebaseFirestore.instance;
      
      const useEmulator = bool.fromEnvironment('USE_FIRESTORE_EMULATOR');
      
      if (useEmulator) {
        await _configureEmulators(firestore, analytics);
      } else {
        print('ℹ️ Using production Firebase instance');
      }
      
      final localWeatherService = await LocalWeatherService.init();
      final firebaseWeatherService = await FirebaseWeatherService.init();
      
      _instance = WeatherService._(
        localWeatherService: localWeatherService,
        firebaseWeatherService: firebaseWeatherService,
        firestore: firestore,
        analytics: analytics,
      );
      
      _instance!._isEmulator = useEmulator;
      await _instance!._initialize();
      
      await analytics.logEvent(
        name: 'weather_service_init',
        parameters: {
          'status': 'success',
          'mode': useEmulator ? 'emulator' : 'production'
        }
      );
      
      return _instance!;
    } catch (e, stack) {
      print('❌ Error initializing WeatherService: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  static Future<void> _configureEmulators(
    FirebaseFirestore firestore,
    FirebaseAnalytics analytics
  ) async {
    print('🔧 Configuring Firebase emulators');
    try {
      // Configure emulators
      firestore.useFirestoreEmulator('localhost', 8083);
      
      print('⏳ Waiting for emulators to be ready...');
      await Future.delayed(_emulatorStartupDelay);
      
      // Verify emulator connection
      await _verifyEmulatorConnection(firestore, analytics);
      
    } catch (e, stack) {
      print('❌ Failed to configure Firebase emulators: $e');
      await analytics.logEvent(
        name: 'emulator_connection',
        parameters: {
          'status': 'error',
          'error': e.toString(),
          'stack_trace': stack.toString()
        }
      );
      rethrow;
    }
  }

  static Future<void> _verifyEmulatorConnection(
    FirebaseFirestore firestore,
    FirebaseAnalytics analytics
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        await firestore.collection('_health').doc('status').set({
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'ok'
        });
        
        print('✅ Successfully connected to Firebase emulators');
        await analytics.logEvent(
          name: 'emulator_connection',
          parameters: {'status': 'success'}
        );
        return;
        
      } catch (e) {
        retryCount++;
        print('⚠️ Emulator health check failed (attempt $retryCount): $e');
        
        if (retryCount >= maxRetries) {
          await analytics.logEvent(
            name: 'emulator_health_check',
            parameters: {
              'status': 'failed',
              'error': e.toString(),
              'attempts': retryCount
            }
          );
          throw Exception('Failed to verify emulator connection after $maxRetries attempts');
        }
        
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize any background tasks or listeners here
      _isInitialized = true;
      await _analytics.logEvent(
        name: 'weather_service_ready',
        parameters: {'status': 'success'}
      );
    } catch (e, stack) {
      await _analytics.logEvent(
        name: 'weather_service_ready',
        parameters: {
          'status': 'error',
          'error': e.toString(),
          'stack_trace': stack.toString()
        }
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      print('🌐 Attempting to fetch weather data from Firestore...');
      final pipelineData = await _getPipelineForecast();
      print('🔥 Pipeline data in getCurrentWeather:');
      print(pipelineData);
      if (pipelineData != null && _isValidPipelineData(pipelineData)) {
        final currentWeather = _extractCurrentWeather(pipelineData);
        await _localWeather.saveCurrentWeather(currentWeather);
        await _analytics?.logEvent(
          name: 'weather_fetch',
          parameters: {'source': 'pipeline'}
        );
        return currentWeather;
      }
      print('❌ Pipeline data invalid or null.');
      throw Exception('No valid pipeline weather data found');
    } catch (e, stack) {
      print('❌ Error in getCurrentWeather: $e');
      print(stack);
      rethrow;
    }
  }

  bool _isValidPipelineData(Map<String, dynamic> data) {
    // Accept if precipitation_mm is present at the top level
    return data.containsKey('precipitation_mm');
  }

  bool _isDataFresh(Map<String, dynamic> data) {
    try {
      final timestamp = DateTime.parse(data['timestamp']);
      final now = DateTime.now();
      return now.difference(timestamp).inHours < 24;
    } catch (e) {
      return false;
    }
  }

  Future<T?> _retryWithBackoff<T>(
    Future<T?> Function() operation, {
    int maxRetries = 3,
    Future<void> Function(dynamic error, int attempt)? onRetry,
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final result = await operation();
        if (attempt > 0) {
          await _analytics?.logEvent(
            name: 'retry_success',
            parameters: {
              'attempts_needed': attempt,
              'timestamp': DateTime.now().toIso8601String()
            }
          );
        }
        return result;
      } catch (e, stack) {
        attempt++;
        if (attempt == maxRetries) {
          await _analytics?.logEvent(
            name: 'retry_exhausted',
            parameters: {
              'error': e.toString(),
              'stack_trace': stack.toString(),
              'max_retries': maxRetries,
              'timestamp': DateTime.now().toIso8601String()
            }
          );
          return null;
        }
        
        if (onRetry != null) {
          await onRetry(e, attempt);
        }
        
        final waitTime = Duration(
          milliseconds: (pow(2, attempt) * 1000).toInt() + 
                       Random().nextInt(1000)
        );
        await Future.delayed(waitTime);
      }
    }
    return null;
  }

  Map<String, dynamic> _extractCurrentWeather(Map<String, dynamic> pipelineData) {
    return {
      'precipitation': pipelineData['precipitation_mm'] ?? 0.0,
      'probability': pipelineData['probability'] ?? 1.0,
      'timestamp': pipelineData['updated_at'] ?? DateTime.now().toIso8601String(),
      'source': pipelineData['source'] ?? 'Pipeline Forecast',
      'location': {
        'lat': _defaultLat,
        'lon': _defaultLon,
      },
    };
  }

  Map<String, dynamic> _getEmptyWeatherData() {
    return {
      'precipitation': 0.0,
      'probability': 0.0,
      'timestamp': DateTime.now().toIso8601String(),
      'source': 'No Data Available',
      'location': {
        'lat': _defaultLat,
        'lon': _defaultLon,
      },
    };
  }

  Future<Map<String, dynamic>?> _getPipelineForecast() async {
    try {
      print('🌐 Fetching Firestore document forecast_results/latest...');
      final doc = await _firestore
          .collection('forecast_results')
          .doc('latest')
          .get()
          .timeout(const Duration(seconds: 5));
      if (!doc.exists) {
        print('❌ Document forecast_results/latest does not exist.');
        return null;
      }
      print('🔥 Fetched Firestore data:');
      print(doc.data());
      return doc.data();
    } catch (e, stack) {
      print('❌ Error fetching Firestore document: $e');
      print(stack);
      return null;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchPipelineForecast() {
    try {
      return _firestore
          .collection('forecast_results')
          .doc('latest')
          .snapshots()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: (sink) {
              _analytics.logEvent(
                name: 'pipeline_forecast_timeout',
                parameters: {'timestamp': DateTime.now().toIso8601String()},
              );
              sink.addError(TimeoutException('Pipeline forecast stream timed out'));
              sink.close();
            },
          );
    } catch (e, stackTrace) {
      _analytics.logEvent(
        name: 'pipeline_forecast_error',
        parameters: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getForecast() async {
    try {
      // First try pipeline data
      final pipelineData = await _getPipelineForecast();
      if (pipelineData != null) {
        await _localWeather.saveForecast(pipelineData);
        return pipelineData;
      }
      
      // Fallback to Firebase service
      final firebaseData = await _firebaseWeather.getShortTermForecast();
      if (firebaseData != null) {
        await _localWeather.saveForecast(firebaseData);
        return firebaseData;
      }
      
      // Try local cache
      final cachedData = await _localWeather.getForecast();
      if (cachedData != null) {
        await _analytics?.logEvent(
          name: 'forecast_fetch',
          parameters: {'source': 'cache'}
        );
        return cachedData;
      }
      
      return {
        'days': [],
        'source': 'No Data Available',
        'timestamp': DateTime.now().toIso8601String(),
        'location': {
          'lat': _defaultLat,
          'lon': _defaultLon,
        },
      };
    } catch (e) {
      await _analytics?.logEvent(
        name: 'forecast_fetch_error',
        parameters: {'error': e.toString()}
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSeasonalForecast() async {
    try {
      // First try pipeline data for seasonal forecast
      final pipelineData = await _getPipelineForecast();
      if (pipelineData != null && pipelineData['seasonal'] != null) {
        await _localWeather.saveSeasonalForecast(pipelineData['seasonal']);
        return pipelineData['seasonal'];
      }
      
      // Fallback to Firebase service
      final firebaseData = await _firebaseWeather.getLongTermForecast();
      if (firebaseData != null) {
        await _localWeather.saveSeasonalForecast(firebaseData);
        return firebaseData;
      }
      
      // Try local cache
      final cachedData = await _localWeather.getSeasonalForecast();
      if (cachedData != null) {
        await _analytics?.logEvent(
          name: 'seasonal_forecast_fetch',
          parameters: {'source': 'cache'}
        );
        return cachedData;
      }
      
      return {
        'months': [],
        'source': 'No Data Available',
        'timestamp': DateTime.now().toIso8601String(),
        'location': {
          'lat': _defaultLat,
          'lon': _defaultLon,
        },
      };
    } catch (e) {
      await _analytics?.logEvent(
        name: 'seasonal_forecast_fetch_error',
        parameters: {'error': e.toString()}
      );
      rethrow;
    }
  }
  
  Stream<Map<String, dynamic>?> watchCurrentWeather() {
    return watchPipelineForecast().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return _extractCurrentWeather(data);
    });
  }
  
  Stream<Map<String, dynamic>?> watchSeasonalForecast() {
    return watchPipelineForecast().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return data['seasonal'] as Map<String, dynamic>?;
    });
  }

  static const String _cacheKey = 'weather_forecast_cache';
  
  // Cache methods for WeatherForecast model
  bool _isCacheValid(DateTime timestamp) {
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  Future<WeatherForecast?> _getCachedForecast() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        return WeatherForecast.fromJson(jsonDecode(cached));
      }
    } catch (e) {
      await _analytics?.logEvent(
        name: 'forecast_cache_read_error',
        parameters: {'error': e.toString()}
      );
    }
    return null;
  }

  Future<void> _cacheForecast(WeatherForecast forecast) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(forecast.toJson()));
    } catch (e) {
      await _analytics?.logEvent(
        name: 'forecast_cache_error',
        parameters: {'error': e.toString()}
      );
    }
  }

  Future<void> initializeWeatherData() async {
    try {
      // Check if documents already exist
      final shortTermDoc = await _firestore.collection('weatherForecasts').doc('shortTermForecast').get();
      final longTermDoc = await _firestore.collection('weatherForecasts').doc('longTermForecast').get();

      if (!shortTermDoc.exists) {
        // Short-term forecast data
        await _firestore.collection('weatherForecasts').doc('shortTermForecast').set({
          'current': {
            'temp_c': 28,
            'humidity': 65,
            'precip_mm': 0.0,
            'wind_kph': 12,
          },
          'forecast': {
            'next_24h': {
              'precip_chance': 30,
              'precip_mm': 2.5,
              'confidence': 0.85,
            }
          },
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }

      if (!longTermDoc.exists) {
        // Long-term forecast data
        await _firestore.collection('weatherForecasts').doc('longTermForecast').set({
          'seasonal_outlook': {
            'next_3_months': {
              'trend': 'normal',
              'precip_anomaly': '+5%',
              'confidence': 0.75,
            }
          },
          'drought_risk': {
            'level': 'bajo',
            'confidence': 0.80,
          },
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error initializing weather data: $e');
      // Create a basic error document to show something to the user
      await _firestore.collection('weatherForecasts').doc('error_status').set({
        'error': 'Unable to initialize weather data',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> updateCurrentWeather() async {
    try {
      await _firestore.collection('weatherForecasts').doc('shortTermForecast').set({
        'current': {
          'temp_c': 27 + (DateTime.now().hour % 5),
          'humidity': 60 + (DateTime.now().minute % 20),
          'precip_mm': 0.0,
          'wind_kph': 10 + (DateTime.now().minute % 10),
        },
        'forecast': {
          'next_24h': {
            'precip_chance': 30,
            'precip_mm': 2.5,
            'confidence': 0.85,
          }
        },
        'lastUpdated': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating weather data: $e');
    }
  }

  /// Fetches monthly temperature forecasts from Firestore (weather/tahcabo_forecast, field: forecasts)
  Future<List<Map<String, dynamic>>> getMonthlyTemperatureForecasts() async {
    try {
      final doc = await _firestore.collection('weather').doc('tahcabo_forecast').get();
      if (!doc.exists) {
        print('❌ Document weather/tahcabo_forecast does not exist.');
        return [];
      }
      final data = doc.data();
      if (data == null || !data.containsKey('forecasts')) {
        print('❌ No forecasts field in weather/tahcabo_forecast.');
        return [];
      }
      final forecasts = data['forecasts'] as List<dynamic>;
      return forecasts.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e, stack) {
      print('❌ Error fetching monthly temperature forecasts: $e');
      print(stack);
      return [];
    }
  }
}