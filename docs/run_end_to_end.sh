#!/bin/bash

# Exit on error
set -e

echo "🚀 Running end-to-end setup for Mayan Roots App..."

# Step 1: Start Firebase emulators
echo "📊 Starting Firebase emulators..."
firebase emulators:start --only firestore,auth &
EMULATOR_PID=$!

# Wait for emulators to start
echo "⏳ Waiting for emulators to start..."
sleep 10

# Step 2: Set up the forecast pipeline
echo "🔄 Setting up the forecast pipeline..."
./docs/setup_forecast_pipeline.sh

# Step 3: Run the Flutter app with emulators
echo "📱 Running the Flutter app with emulators..."
./docs/run_app_with_emulators.sh

# Clean up
echo "🧹 Cleaning up..."
kill $EMULATOR_PID

echo "✅ End-to-end setup complete!"
echo "You can now use the app with the forecast data from the emulators." 