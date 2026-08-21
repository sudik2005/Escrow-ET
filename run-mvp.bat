@echo off
setlocal enabledelayedexpansion
title Escrow ET — MVP Runner

set ROOT=%~dp0
set BACKEND=%ROOT%backend
set MOBILE=%ROOT%mobile
set VENV=%BACKEND%\.venv\Scripts\python.exe
set APK=%MOBILE%\build\app\outputs\flutter-apk\app-release.apk

echo.
echo  =====================================================
echo   ESCROW ET — MVP RUNNER
echo  =====================================================
echo.

:: ── STEP 1: Check .venv exists ───────────────────────────────────────────────
if not exist "%VENV%" (
    echo  [ERROR] Backend virtual environment not found.
    echo.
    echo  Fix it by running these commands once:
    echo    cd "%BACKEND%"
    echo    python -m venv .venv
    echo    .venv\Scripts\python.exe -m pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

:: ── STEP 2: Detect local Wi-Fi IP automatically ───────────────────────────────
echo  [1/3] Detecting local IP address...

for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command ^
  "(Get-NetIPAddress -AddressFamily IPv4 ^| Where-Object { $_.PrefixOrigin -eq 'Dhcp' } ^| Select-Object -First 1).IPAddress"`) do set LOCAL_IP=%%i

if "!LOCAL_IP!"=="" (
    echo         Wi-Fi DHCP address not found. Trying fallback...
    for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command ^
      "(Get-NetIPAddress -AddressFamily IPv4 ^| Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.*' } ^| Select-Object -First 1).IPAddress"`) do set LOCAL_IP=%%i
)

if "!LOCAL_IP!"=="" (
    echo         Still no IP found. Defaulting to 127.0.0.1
    echo         The APK will only work on an emulator, not a real device.
    set LOCAL_IP=127.0.0.1
)

set API_URL=http://!LOCAL_IP!:8000/api
echo         IP detected : !LOCAL_IP!
echo         API base URL: !API_URL!
echo.

:: ── STEP 3: Start Django in a new window ─────────────────────────────────────
echo  [2/3] Starting Django backend...

set DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2,!LOCAL_IP!

start "Escrow ET — Django" cmd /k ^
  "cd /d "%BACKEND%" ^&^& ^
   set DJANGO_ALLOWED_HOSTS=!DJANGO_ALLOWED_HOSTS! ^&^& ^
   echo  Backend running at http://0.0.0.0:8000 ^&^& ^
   echo  Reachable on device at !API_URL! ^&^& ^
   echo. ^&^& ^
   "%VENV%" manage.py runserver 0.0.0.0:8000"

echo         Django window opened. Waiting 4 seconds...
timeout /t 4 /nobreak >nul
echo.

:: ── STEP 4: Build Flutter APK with the detected IP ────────────────────────────
echo  [3/3] Building Flutter APK (this takes ~2 minutes)...
echo.

cd /d "%MOBILE%"
flutter build apk --release --dart-define=API_BASE_URL=!API_URL!

if errorlevel 1 (
    echo.
    echo  [ERROR] Flutter build failed. Check the output above.
    echo.
    pause
    exit /b 1
)

:: ── Done ─────────────────────────────────────────────────────────────────────
echo.
echo  =====================================================
echo   BUILD COMPLETE
echo  =====================================================
echo.
echo   APK file : %APK%
echo   API URL  : !API_URL!
echo.
echo   NEXT STEPS:
echo   1. Make sure your phone is on the SAME Wi-Fi as this PC
echo   2. Transfer the APK (USB / WhatsApp / Google Drive)
echo   3. Install it and open the app
echo   4. Register as SELLER, then BUYER on another account
echo   5. Seller creates Payment Link -> Buyer pays via Chapa
echo   6. Seller shows QR -> Buyer scans to confirm delivery
echo.
echo   Keep the Django window open while testing.
echo.

:: Open the folder containing the APK in Explorer
explorer /select,"%APK%"

pause
endlocal
