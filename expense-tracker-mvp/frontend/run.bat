@echo off

echo ===================================
echo Expense Tracker Frontend
echo ===================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    exit /b 1
)

REM Get Flutter dependencies
echo Getting Flutter dependencies...
flutter pub get
echo.

echo ===================================
echo Starting Flutter Web App...
echo The app will open in Chrome
echo ===================================
echo.

REM Run the app
flutter run -d chrome
