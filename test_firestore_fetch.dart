import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  print('🌐 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🌐 Fetching Firestore document forecast_results/latest...');
  final doc = await FirebaseFirestore.instance
      .collection('forecast_results')
      .doc('latest')
      .get();

  if (!doc.exists) {
    print('❌ Document does not exist.');
  } else {
    print('✅ Document data:');
    print(doc.data());
  }
} 