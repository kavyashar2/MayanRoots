#!/bin/bash

# Exit on error
set -e

echo "🚀 Setting up the forecast pipeline..."

# Check if forecast_pipeline directory exists
if [ ! -d "../forecast_pipeline" ]; then
  echo "❌ forecast_pipeline directory not found. Please clone it first:"
  echo "git clone https://github.com/your-org/forecast_pipeline.git ../forecast_pipeline"
  exit 1
fi

# Navigate to forecast_pipeline directory
cd ../forecast_pipeline

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Check if serviceAccountKey.json exists
if [ ! -f "functions/serviceAccountKey.json" ]; then
  echo "⚠️ serviceAccountKey.json not found in functions directory."
  echo "Please obtain it from Firebase Console and place it in the functions directory."
  echo "See docs/serviceAccountKey.json for instructions."
  exit 1
fi

# Navigate to functions directory
cd functions

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Set environment variables
echo "🔧 Setting environment variables..."
export FIRESTORE_EMULATOR_HOST=localhost:8081
export GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json

# Run the pipeline
echo "▶️ Running the pipeline..."
node index.mjs

echo "✅ Setup complete! The forecast data should now be in the Firestore emulator."
echo "You can verify this by checking the Firestore emulator UI at http://127.0.0.1:4004/firestore" 