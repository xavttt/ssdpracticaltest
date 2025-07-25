@echo off
REM SonarQube Analysis Script for Windows
REM This script runs SonarQube analysis with token authentication

echo 🔍 Running SonarQube Analysis...
echo.

REM Check if SonarQube is running
curl -f http://localhost:9000/api/system/status >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ SonarQube is not running on localhost:9000
    echo    Please start SonarQube first: docker-compose up -d sonarqube
    pause
    exit /b 1
)

echo ✅ SonarQube is running

REM Set the token environment variable
set SONAR_TOKEN=squ_04a5f73594296b442672e1f92a633494c15fddc3

REM Check if sonar-scanner is available
where sonar-scanner >nul 2>&1
if %errorlevel% neq 0 (
    echo 📦 SonarQube scanner not found. Installing...
    npm install -g sonarqube-scanner
    if %errorlevel% neq 0 (
        echo ❌ Failed to install SonarQube scanner
        echo    Please install manually: npm install -g sonarqube-scanner
        pause
        exit /b 1
    )
)

echo 🚀 Starting SonarQube analysis...
echo.

REM Run SonarQube analysis
sonar-scanner
if %errorlevel% equ 0 (
    echo.
    echo ✅ SonarQube analysis completed successfully
    echo 🌐 View results at: http://localhost:9000/dashboard?id=secure-web-app
) else (
    echo.
    echo ❌ SonarQube analysis failed with error code %errorlevel%
    echo 💡 Check the output above for details
)

echo.
pause
