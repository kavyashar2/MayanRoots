#!/bin/bash

# Exit on error
set -e

echo "🚀 Running the Flutter app with Firebase emulators..."

# Check if Firebase emulators are running
if ! curl -s http://localhost:4004 > /dev/null; then
  echo "⚠️ Firebase emulators don't seem to be running."
  echo "Please start them with: firebase emulators:start --only firestore,auth"
  exit 1
fi

# Clean and get dependencies
echo "🧹 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Check if Android emulator is running
echo "📱 Checking Android emulator..."
flutter devices | grep -q "emulator"
if [ $? -ne 0 ]; then
  echo "⚠️ No Android emulator detected."
  echo "Please start an Android emulator from Android Studio's Device Manager."
  echo "Then run this script again."
  exit 1
fi

# Get the emulator ID
EMULATOR_ID=$(flutter devices | grep "emulator" | awk '{print $1}')
echo "📱 Using emulator: $EMULATOR_ID"

# Run the app with emulator support
echo "▶️ Running the app with emulator support..."
flutter run --dart-define=USE_FIRESTORE_EMULATOR=true -d $EMULATOR_ID

echo "✅ App should now be running with emulator support!"
echo "You can verify this by checking the 'Pronóstico del Clima' screen." 