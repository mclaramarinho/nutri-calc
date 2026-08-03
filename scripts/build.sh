#!/bin/bash
set -e

# Run clean and get for both options
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Fetching dependencies..."
flutter pub get

# Check if the user passed the "watch" argument
if [ "$1" == "watch" ]; then
    echo "👀 Starting build_runner in WATCH mode..."
    dart run build_runner watch --delete-conflicting-outputs
else
    echo "⚙️ Running a one-time build..."
    dart run build_runner build --delete-conflicting-outputs
    echo "✅ Complete!"
fi
