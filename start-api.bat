@echo off
title Escrow ET API
cd /d "%~dp0backend"

if not exist ".venv\Scripts\python.exe" (
  echo Missing backend\.venv
  echo Create it first:  python -m venv .venv
  echo Then:  .venv\Scripts\python.exe -m pip install -r requirements.txt
  pause
  exit /b 1
)

set DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2
echo Starting API at http://127.0.0.1:8000/
echo Leave this window open. Then run:  flutter run
echo.
".venv\Scripts\python.exe" manage.py runserver 127.0.0.1:8000
pause
