@echo off

echo ===================================
echo Expense Tracker Backend
echo ===================================
echo.

REM Check if virtual environment exists
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
    echo.
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt
echo.

REM Create necessary directories
if not exist "uploads\" mkdir uploads
if not exist "data\" mkdir data

echo ===================================
echo Starting Flask server...
echo Backend will run on http://localhost:5000
echo ===================================
echo.

REM Run the app
python app.py
