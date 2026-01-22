#!/bin/bash

# Expense Tracker Frontend - Quick Start Script

echo "==================================="
echo "Expense Tracker Frontend"
echo "==================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get
echo ""

echo "==================================="
echo "Starting Flutter Web App..."
echo "The app will open in Chrome"
echo "==================================="
echo ""

# Run the app
flutter run -d chrome
