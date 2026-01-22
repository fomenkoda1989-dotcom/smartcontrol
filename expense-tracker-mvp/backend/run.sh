#!/bin/bash

# Expense Tracker Backend - Quick Start Script

echo "==================================="
echo "Expense Tracker Backend"
echo "==================================="
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo ""
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt
echo ""

# Create necessary directories
mkdir -p uploads data

echo "==================================="
echo "Starting Flask server..."
echo "Backend will run on http://localhost:5000"
echo "==================================="
echo ""

# Run the app
python app.py
