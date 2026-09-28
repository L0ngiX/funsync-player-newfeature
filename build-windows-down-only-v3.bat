@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
set "ROOT=%CD%"
set "npm_config_ignore_scripts=false"

echo.
echo =========================================================
echo   FunSync Player 0.9.2 - Down Only v3
echo =========================================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js was not found in PATH.
  pause
  exit /b 1
)
where python >nul 2>nul
if errorlevel 1 (
  echo ERROR: Python was not found in PATH.
  pause
  exit /b 1
)

echo Node:
node --version
echo Python:
python --version

echo.

echo [1/7] Checking FFmpeg...
if not exist "%ROOT%\ffmpeg\ffmpeg.exe" (
  where ffmpeg >nul 2>nul
  if errorlevel 1 goto :missing_ffmpeg
  if not exist "%ROOT%\ffmpeg" mkdir "%ROOT%\ffmpeg"
  for /f "delims=" %%F in ('where ffmpeg') do copy /Y "%%F" "%ROOT%\ffmpeg\ffmpeg.exe" >nul
)
if not exist "%ROOT%\ffmpeg\ffprobe.exe" (
  where ffprobe >nul 2>nul
  if errorlevel 1 goto :missing_ffprobe
  for /f "delims=" %%F in ('where ffprobe') do copy /Y "%%F" "%ROOT%\ffmpeg\ffprobe.exe" >nul
)
echo OK: FFmpeg binaries found.

echo.
echo [2/7] Installing Node dependencies (including Electron)...
call npm install --include=optional --foreground-scripts
if errorlevel 1 goto :fail
call npm rebuild electron --foreground-scripts
if errorlevel 1 goto :fail
call npm rebuild @serialport/bindings-cpp --foreground-scripts
if errorlevel 1 echo WARNING: SerialPort native rebuild failed; continuing.
if not exist "%ROOT%\node_modules\electron\package.json" goto :electron_fail
node -e "const e=require('./node_modules/electron/package.json'); console.log('Electron version:',e.version)"
if errorlevel 1 goto :electron_fail

echo.
echo [3/7] Verifying the new Down Only logic...
call npx vitest run tests/unit/buttplug-down-speed.test.js
if errorlevel 1 goto :fail

echo OK: Down Only direction/speed tests passed.

echo.
echo [4/7] Creating Python virtual environment...
if not exist "%ROOT%\backend\.venv\Scripts\python.exe" (
  python -m venv "%ROOT%\backend\.venv"
  if errorlevel 1 goto :fail
)
"%ROOT%\backend\.venv\Scripts\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto :fail
"%ROOT%\backend\.venv\Scripts\python.exe" -m pip install -r "%ROOT%\backend\requirements.txt"
if errorlevel 1 goto :fail
"%ROOT%\backend\.venv\Scripts\python.exe" -m pip install pyinstaller
if errorlevel 1 goto :fail

echo.
echo [5/7] Building Python backend...
if exist "%ROOT%\backend-dist" rmdir /s /q "%ROOT%\backend-dist"
mkdir "%ROOT%\backend-dist"
"%ROOT%\backend\.venv\Scripts\python.exe" -m PyInstaller --distpath "%ROOT%\backend-dist" --workpath "%ROOT%\build\pyinstaller" --clean "%ROOT%\backend\funsync-backend.spec"
if errorlevel 1 goto :fail
if not exist "%ROOT%\backend-dist\funsync-backend.exe" goto :backend_fail
echo OK: funsync-backend.exe created.

echo.
echo [6/7] Fetching Twemoji assets...
node "%ROOT%\scripts\fetch-twemoji.mjs"
if errorlevel 1 goto :fail
set "EMOJI_COUNT=0"
for %%F in ("%ROOT%\renderer\assets\emoji\*.svg") do set /a EMOJI_COUNT+=1
if !EMOJI_COUNT! LSS 100 goto :emoji_fail
echo OK: !EMOJI_COUNT! emoji SVG files.

echo.
echo [7/7] Building Windows installer and portable EXE...
call npx electron-builder --config electron-builder.yml
if errorlevel 1 goto :fail

echo.
echo =========================================================
echo   BUILD SUCCESSFUL
echo =========================================================
echo.
echo Output folder:
echo   %ROOT%\dist\
echo.
echo The new control is shown for Buttplug devices with Oscillate:
echo   Fixed speed -> Script speed / Down only / Both directions
echo   Value      -> strokes/s
 echo.
echo Up override means: 100 -^> 0 keeps script speed; 0 -^> 100 uses the configured speed (including 0).
echo BLE/Posy code was not modified.
echo.
pause
exit /b 0

:missing_ffmpeg
echo ERROR: ffmpeg.exe was not found. Put it in %ROOT%\ffmpeg\
pause
exit /b 1
:missing_ffprobe
echo ERROR: ffprobe.exe was not found. Put it next to ffmpeg.exe in %ROOT%\ffmpeg\
pause
exit /b 1
:electron_fail
echo ERROR: Electron package is not installed correctly.
pause
exit /b 1
:backend_fail
echo ERROR: PyInstaller did not create backend-dist\funsync-backend.exe.
pause
exit /b 1
:emoji_fail
echo ERROR: Twemoji download produced fewer than 100 SVG files.
pause
exit /b 1
:fail
echo.
echo =========================================================
echo   BUILD FAILED
echo =========================================================
echo Read the error above.
echo.
pause
exit /b 1
