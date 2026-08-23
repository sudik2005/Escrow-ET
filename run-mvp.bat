@echo off
setlocal enabledelayedexpansion
title Escrow ET — MVP Runner

set ROOT=%~dp0
set BACKEND=%ROOT%backend
set MOBILE=%ROOT%mobile
set VENV=%BACKEND%\.venv\Scripts\python.exe
set APK=%MOBILE%\build\app\outputs\flutter-apk\app-release.apk
set LAUNCHER=%TEMP%\escrow_django_start.bat

echo.
echo  =====================================================
echo   ESCROW ET  —  MVP RUNNER
echo  =====================================================
echo.

:: ── Check .venv ───────────────────────────────────────────────────────────────
if not exist "%VENV%" (
    echo  [ERROR] .venv not found at %BACKEND%\.venv
    echo.
    echo  Run once to set it up:
    echo    cd "%BACKEND%"
    echo    python -m venv .venv
    echo    .venv\Scripts\python.exe -m pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

:: ── Detect Wi-Fi / DHCP IP ────────────────────────────────────────────────────
echo  [1/4] Detecting local IP...

for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command ^
  "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq 'Dhcp' } | Select-Object -First 1).IPAddress"`) do set LOCAL_IP=%%i

if "!LOCAL_IP!"=="" (
    for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command ^
      "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.*' } | Select-Object -First 1).IPAddress"`) do set LOCAL_IP=%%i
)

if "!LOCAL_IP!"=="" (
    echo  [WARN] No IP found — defaulting to 127.0.0.1 (emulator only)
    set LOCAL_IP=127.0.0.1
)

set API_URL=http://!LOCAL_IP!:8000/api
set ALLOWED=localhost,127.0.0.1,10.0.2.2,!LOCAL_IP!

echo         IP  : !LOCAL_IP!
echo         URL : !API_URL!
echo.

:: ── Run migrations (inline, same window) ─────────────────────────────────────
echo  [2/4] Applying database migrations...
cd /d "%BACKEND%"
set DJANGO_ALLOWED_HOSTS=!ALLOWED!
"%VENV%" manage.py migrate
if errorlevel 1 (
    echo.
    echo  [ERROR] Migrations failed. Check your DATABASE_URL in .env
    echo.
    pause
    exit /b 1
)
echo.

:: ── Write a launcher script for the Django window ────────────────────────────
:: (avoids all quoting / delayed-expansion issues with start "..." cmd /k "...")
(
    echo @echo off
    echo title Escrow ET — Django Server
    echo cd /d "!BACKEND!"
    echo set DJANGO_ALLOWED_HOSTS=!ALLOWED!
    echo echo.
    echo echo  Django is running at http://0.0.0.0:8000
    echo echo  Reachable from your phone at !API_URL!
    echo echo  Keep this window open while testing.
    echo echo.
    echo "!VENV!" manage.py runserver 0.0.0.0:8000 --noreload
    echo pause
) > "%LAUNCHER%"

:: ── Start Django in its own window ───────────────────────────────────────────
echo  [3/4] Starting Django server in a new window...
start "Escrow ET — Django" cmd /k "%LAUNCHER%"

echo         Waiting 5 seconds for the server to come up...
timeout /t 5 /nobreak >nul
echo.

:: ── Build the APK ─────────────────────────────────────────────────────────────
echo  [4/4] Building Flutter APK (this takes ~2 minutes)...
echo.
cd /d "%MOBILE%"
flutter build apk --release --dart-define=API_BASE_URL=!API_URL!

if errorlevel 1 (
    echo.
    echo  [ERROR] Flutter build failed. Check output above.
    echo.
    pause
    exit /b 1
)

:: ── Done ──────────────────────────────────────────────────────────────────────
echo.
echo  =====================================================
echo   BUILD COMPLETE
echo  =====================================================
echo.
echo   APK  : %APK%
echo   API  : !API_URL!
echo.
echo   Steps:
echo   1. Phone must be on the SAME Wi-Fi as this PC
echo   2. Transfer APK  (USB / WhatsApp / Google Drive)
echo   3. Install and open the app
echo   4. Keep the Django window open while testing
echo.

explorer /select,"%APK%"
pause
endlocal
