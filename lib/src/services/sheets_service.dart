import 'package:gsheets/gsheets.dart';
import '../config/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';

class SheetsServiceException implements Exception {
  final String message;
  final dynamic originalError;
  
  SheetsServiceException(this.message, [this.originalError]);
  
  @override
  String toString() => 'SheetsServiceException: $message${originalError != null ? ' ($originalError)' : ''}';
}

class SheetsService {
  static const _spreadsheetId = '10-ephI7is5DUne95VfjL49yyk56zWH1Iw3Z14Ul8yxo';
  static const _workSheetTitle = 'Reports';
  static const _cacheKey = 'sheets_service_last_init';
  static const _cacheDuration = Duration(hours: 1);
  static const _maxRetries = 3;
  static const _retryDelay = Duration(seconds: 2);
  static const _connectionTimeout = Duration(seconds: 10);

  // For demo mode
  static bool _demoMode = true; // Set to true for the demo
  static final List<List<String>> _demoReports = [];

  static SheetsService? _instance;
  static GSheets? _gsheets;
  static Worksheet? _worksheet;
  static bool _isInitialized = false;
  static Future<void>? _initializationFuture;

  // Private constructor
  SheetsService._();

  // Factory constructor to return the singleton instance
  factory SheetsService() {
    _instance ??= SheetsService._();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;
  bool get isDemoMode => _demoMode;
  
  // Enable or disable demo mode
  void setDemoMode(bool enabled) {
    _demoMode = enabled;
    if (enabled) {
      _isInitialized = true;
    } else {
      _isInitialized = false;
    }
  }

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await operation().timeout(_connectionTimeout);
      } on TimeoutException {
        attempts++;
        if (attempts == _maxRetries) {
          throw SheetsServiceException(
            'Connection timed out after $_maxRetries attempts. Please check your internet connection.',
          );
        }
        await Future.delayed(_retryDelay * attempts);
      } on SocketException catch (e) {
        attempts++;
        if (attempts == _maxRetries) {
          throw SheetsServiceException(
            'Network error after $_maxRetries attempts. Please check your internet connection.',
            e
          );
        }
        await Future.delayed(_retryDelay * attempts);
      } catch (e) {
        throw SheetsServiceException('Operation failed', e);
      }
    }
    throw SheetsServiceException('Max retries exceeded');
  }

  // Initialize the service
  Future<void> init() async {
    // If in demo mode, immediately set as initialized
    if (_demoMode) {
      _isInitialized = true;
      return;
    }

    if (_isInitialized) return;

    // If already initializing, wait for that to complete
    if (_initializationFuture != null) {
      try {
        await _initializationFuture;
        return;
      } catch (_) {
        // If previous initialization failed, allow retry
        _initializationFuture = null;
      }
    }

    _initializationFuture = _initialize();
    try {
      await _initializationFuture;
    } finally {
      _initializationFuture = null;
    }
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastInit = prefs.getInt(_cacheKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // If last init was recent and we have a worksheet, skip initialization
      if (_worksheet != null && now - lastInit < _cacheDuration.inMilliseconds) {
        _isInitialized = true;
        return;
      }

      // Initialize GSheets with retry
      await _withRetry(() async {
        // Try to resolve the DNS manually first
        try {
          await InternetAddress.lookup('oauth2.googleapis.com');
        } catch (_) {
          // If DNS lookup fails, we'll continue anyway as the request might still work
        }

        _gsheets ??= GSheets(Credentials.serviceAccountJson);
        
        // Get spreadsheet
        final spreadsheet = await _gsheets!.spreadsheet(_spreadsheetId);
        if (spreadsheet == null) {
          throw SheetsServiceException('Failed to access spreadsheet');
        }
        
        // Get or create worksheet
        _worksheet = spreadsheet.worksheetByTitle(_workSheetTitle);
        if (_worksheet == null) {
          _worksheet = await spreadsheet.addWorksheet(_workSheetTitle);
          if (_worksheet == null) {
            throw SheetsServiceException('Failed to create worksheet');
          }
        }
      });

      await prefs.setInt(_cacheKey, now);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      if (e is SheetsServiceException) {
        rethrow;
      }
      throw SheetsServiceException('Initialization failed', e);
    }
  }

  Future<bool> insertReport({
    required String reportName,
    required String category,
    required String description,
    String? location,
    String? cropYield,
    String? email,
    required String incidentDate,
  }) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      // If in demo mode, just store in memory
      if (_demoMode) {
        final timestamp = DateTime.now().toIso8601String();
        final rowData = [
          timestamp,
          reportName,
          category,
          description,
          location ?? '',
          cropYield ?? '',
          email ?? '',
          incidentDate,
        ];
        _demoReports.add(rowData);
        return true;
      }

      if (_worksheet == null) {
        throw SheetsServiceException('Service not properly initialized');
      }

      final timestamp = DateTime.now().toIso8601String();
      final rowData = [
        timestamp,
        reportName,
        category,
        description,
        location ?? '',
        cropYield ?? '',
        email ?? '',
        incidentDate,
      ];
      
      final success = await _withRetry(() => _worksheet!.values.appendRow(rowData));
      if (!success) {
        throw SheetsServiceException('Failed to append report data');
      }
      return true;
    } catch (e) {
      if (e is SheetsServiceException) {
        rethrow;
      }
      throw SheetsServiceException('Failed to insert report', e);
    }
  }

  Future<List<List<String>>> getReports() async {
    try {
      if (!_isInitialized) {
        await init();
      }

      // If in demo mode, return demo reports
      if (_demoMode) {
        return _demoReports;
      }

      if (_worksheet == null) {
        throw SheetsServiceException('Service not properly initialized');
      }

      final reports = await _withRetry(() => _worksheet!.values.allRows());
      return reports ?? [];
    } catch (e) {
      if (e is SheetsServiceException) {
        rethrow;
      }
      throw SheetsServiceException('Failed to fetch reports', e);
    }
  }
} 