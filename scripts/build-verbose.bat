@echo off
cd /d "%~dp0.."

echo =====================================
echo ESPHome Build - VERBOSE MODE
echo =====================================
echo.
echo Deze build toont meer output en gebruikt een persistent cache.
echo Dit helpt om te zien waar de build precies is.
echo.
echo Druk op een toets om te starten...
pause >nul

docker run --rm -v "%cd%":/config -v esphome-cache:/cache -e ESPHOME_VERBOSE=1 -it ghcr.io/esphome/esphome compile esphome-parking-assistant.yaml

echo.
echo =====================================
if %ERRORLEVEL% EQU 0 (
    echo BUILD GESLAAGD!
    echo.
    echo Firmware staat in: .esphome\build\esphome-web-2410f0\
    echo.
    echo Gebruik upload.bat om te uploaden naar je ESP32
) else (
    echo BUILD MISLUKT - Error code: %ERRORLEVEL%
    echo Check de output hierboven voor details.
)
echo =====================================
echo.
pause

