import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: throw UnsupportedError('Platform not supported');
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDo6exfC2UHZnzKyFNVDRjrt6KO24zkk5M',
    appId: '1:176728544148:web:55230fd58636811e557581',
    messagingSenderId: '176728544148',
    projectId: 'mayan-roots-43fe8',
    authDomain: 'mayan-roots-43fe8.firebaseapp.com',
    storageBucket: 'mayan-roots-43fe8.appspot.com',
  );

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyDo6exfC2UHZnzKyFNVDRjrt6KO24zkk5M',
    appId: '1:176728544148:android:30d38c278488b6ec557581',
    messagingSenderId: '176728544148',
    projectId: 'mayan-roots-43fe8',
    storageBucket: 'mayan-roots-43fe8.appspot.com',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyDo6exfC2UHZnzKyFNVDRjrt6KO24zkk5M',
    appId: '1:176728544148:ios:3fb73d4dcb01a7bc557581',
    messagingSenderId: '176728544148',
    projectId: 'mayan-roots-43fe8',
    storageBucket: 'mayan-roots-43fe8.appspot.com',
    iosBundleId: 'com.example.mayanRootsApp',
  );
} 