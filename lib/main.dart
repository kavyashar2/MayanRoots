import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mayan_roots_app/src/maps_page.dart';
import 'package:mayan_roots_app/src/agricultural_cycles_page.dart';
import 'package:mayan_roots_app/src/pages/community_page.dart';
import 'package:mayan_roots_app/src/pages/reports_page.dart';
import 'package:mayan_roots_app/src/help_page.dart';
import 'package:mayan_roots_app/src/settings_page.dart';
import 'src/services/localization_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'src/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'dart:async';  // Add this import for TimeoutException
import 'package:firebase_analytics/firebase_analytics.dart';
import 'src/services/weather_service.dart';

// Import each cycle step page
import 'package:mayan_roots_app/src/pages/cycle_step_1.dart';
import 'package:mayan_roots_app/src/pages/cycle_step_2.dart';
import 'package:mayan_roots_app/src/pages/cycle_step_3.dart';
import 'package:mayan_roots_app/src/pages/cycle_step_4.dart';
import 'package:mayan_roots_app/src/pages/cycle_step_5.dart';
import 'package:mayan_roots_app/src/pages/cycle_step_6.dart';
import 'package:mayan_roots_app/src/pages/cycle_step_7.dart';
import 'package:mayan_roots_app/src/pages/cycle_step_8.dart';
import 'package:mayan_roots_app/src/pages/weather_forecast_page.dart';

void _log(String message) {
  final timestamp = DateTime.now().toIso8601String();
  developer.log('[$timestamp] 🔥 $message', name: 'Firebase');
  debugPrint('[$timestamp] 🔥 $message');
}

Future<void> _cleanupExistingInstances() async {
  _log('Cleaning up existing Firebase instances...');
  
  try {
    final apps = Firebase.apps;
    for (final app in apps) {
      _log('Deleting app: ${app.name}');
      await app.delete();
    }
    _log('Successfully cleaned up ${apps.length} Firebase app(s)');
  } catch (e) {
    _log('Error during cleanup: $e');
    // Continue with initialization even if cleanup fails
  }
}

Future<void> _configureEmulators() async {
  const useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
  
  if (!useEmulator) {
    _log('Using production Firebase instance');
    return;
  }
  
  try {
    _log('Configuring Firebase emulators...');
    
    // Wait for Firebase to be initialized before configuring emulators
    await Future.delayed(Duration(milliseconds: 500));
    
    // Configure Firestore emulator
    _log('Configuring Firestore emulator...');
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8083);
    
    // Configure Auth emulator
    _log('Configuring Auth emulator...');
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    
    _log('Successfully configured emulators');
  } catch (e, stack) {
    _log('Failed to configure emulators: $e');
    _log('Stack trace: $stack');
    // Don't rethrow - allow the app to continue with production Firebase
  }
}

Future<FirebaseApp> _initializeFirebase() async {
  _log('Initializing Firebase...');
  try {
    // Check if default app is already initialized
    if (Firebase.apps.isNotEmpty) {
      _log('Default app already initialized, returning existing instance');
      return Firebase.app();
    }

    // Initialize Firebase with a fresh instance
    _log('Initializing new Firebase instance');
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _log('Firebase initialized successfully: ${app.name}');
    return app;
  } catch (e, stack) {
    _log('Error initializing Firebase: $e');
    _log('Stack trace: $stack');
    rethrow;
  }
}

Future<void> main() async {
  print('🟢 main() started');
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ Flutter bindings initialized');
  await initializeDateFormatting();
  print('✅ Date formatting initialized');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e, stack) {
    print('❌ Firebase initialization failed: $e');
    print(stack);
  }
  try {
    await LocalizationService.instance.init();
    print('✅ LocalizationService initialized');
  } catch (e, stack) {
    print('❌ LocalizationService initialization failed: $e');
    print(stack);
  }
  print('🚀 Calling runApp');
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalizationService.instance,
      child: const App(),
    ),
  );
  print('✅ runApp called');
}