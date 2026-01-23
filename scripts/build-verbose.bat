@echo off
cd /d "%~dp0.."

echo =====================================
echo ESPHome Build - VERBOSE MODE
echo =====================================
echo.
echo This build shows more output and uses a persistent cache.
echo This helps to see where the build is exactly.
echo.
echo Press any key to start...
pause >nul

docker run --rm -v "%cd%":/config -v esphome-cache:/cache -e ESPHOME_VERBOSE=1 -it ghcr.io/esphome/esphome compile esphome-parking-assistant.yaml

echo.
echo =====================================
if %ERRORLEVEL% EQU 0 (
    echo BUILD SUCCEEDED!
    echo.
    echo Firmware is in: .esphome\build\esphome-web-2410f0\
    echo.
    echo Use upload.bat to upload to your ESP32
) else (
    echo BUILD FAILED - Error code: %ERRORLEVEL%
    echo Check the output above for details.
)
echo =====================================
echo.
pause

