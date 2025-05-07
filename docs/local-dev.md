# Local Development Setup

This document provides instructions for setting up the local development environment for the Mayan Roots App, including Firebase emulators and the forecast pipeline.

## Prerequisites

- Flutter SDK (latest version)
- Firebase CLI
- Node.js and npm
- Android Studio with an Android Virtual Device (AVD)
- Java Development Kit (JDK) 17

## Setting Up Firebase Emulators

1. Make sure you have the Firebase CLI installed:
   ```
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```
   firebase login
   ```

3. Start the Firebase emulators:
   ```
   firebase emulators:start --only firestore,auth
   ```

   The emulators will run on the following ports:
   - Firestore: 8081
   - Auth: 9099
   - UI: 4004

## Setting Up the Forecast Pipeline

1. Navigate to the forecast pipeline directory:
   ```
   cd ../forecast_pipeline
   ```

2. Pull the latest changes:
   ```
   git pull origin main
   ```

3. Set up environment variables:
   ```
   export FIRESTORE_EMULATOR_HOST=localhost:8081
   export GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json
   ```

4. Install dependencies and run the pipeline:
   ```
   cd functions
   npm install
   node index.mjs
   ```

   You should see: `✅ Wrote forecast to Firestore`

## Running the Flutter App with Emulators

1. Clean and get dependencies:
   ```
   flutter clean
   flutter pub get
   ```

2. Make sure your Android AVD is running (Device Manager in Android Studio)

3. Run the app with emulator support:
   ```
   flutter run --dart-define=USE_FIRESTORE_EMULATOR=true -d emulator-5554
   ```
   (Replace `emulator-5554` with your AVD's ID if different)

## Verifying End-to-End Flow

1. Emulator UI: Open http://127.0.0.1:4004/firestore → expand forecast_results → latest. Confirm you see a precipitation value & date window.

2. Android emulator: Navigate to the "Pronóstico del Clima" screen. You should see the same precipitation & date window appear.

## Troubleshooting

### Port Conflicts

If you encounter port conflicts when starting the emulators, you can modify the ports in the `firebase.json` file:

```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8081
    },
    "ui": {
      "enabled": true,
      "port": 4004
    }
  }
}
```

### Java/Gradle Issues

If you encounter Java or Gradle issues:

1. Make sure JAVA_HOME is set correctly:
   ```
   export JAVA_HOME=/opt/homebrew/Cellar/openjdk@17/17.0.15/libexec/openjdk.jdk/Contents/Home
   ```

2. Add this to your `~/.zshrc` file to make it permanent:
   ```
   echo 'export JAVA_HOME=/opt/homebrew/Cellar/openjdk@17/17.0.15/libexec/openjdk.jdk/Contents/Home' >> ~/.zshrc
   source ~/.zshrc
   ```

3. Verify Java version:
   ```
   java -version
   ```

### Android Emulator Issues

If the Android emulator fails to start:

1. Open Android Studio
2. Go to Device Manager
3. Create a new virtual device if needed
4. Start the emulator from Android Studio
5. Note the emulator ID (e.g., emulator-5554)
6. Use this ID when running the Flutter app

## Additional Resources

- [Firebase Emulator Suite Documentation](https://firebase.google.com/docs/emulator-suite)
- [Flutter Firebase Documentation](https://firebase.flutter.dev/docs/overview)
- [Android Studio Documentation](https://developer.android.com/studio) 