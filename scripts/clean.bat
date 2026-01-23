@echo off
cd /d "%~dp0.."

echo =====================================
echo ESPHome - Clean Build
echo =====================================
echo.
echo This script clears the local build cache.
echo Use this if the build hangs or gives strange errors.
echo.
echo WARNING: The next build will take longer!
echo.
set /p confirm="Are you sure you want to clean? (y/n): "
if /i not "%confirm%"=="y" (
    echo Cancelled.
    pause
    exit /b
)

echo.
echo Cleaning...

REM Clean local build directory
if exist ".esphome\build" (
    echo Removing .esphome\build...
    rmdir /s /q ".esphome\build"
)

if exist ".esphome\platformio" (
    echo Removing .esphome\platformio...
    rmdir /s /q ".esphome\platformio"
)

REM Optional: also clear Docker cache volume
echo.
set /p cleanvol="Do you also want to clear the Docker cache volume? (y/n): "
if /i "%cleanvol%"=="y" (
    echo Removing Docker cache volume...
    docker volume rm esphome-cache 2>nul
    docker volume create esphome-cache
    echo Docker cache volume recreated.
)

echo.
echo =====================================
echo CLEAN COMPLETED
echo =====================================
echo You can now run build.bat again.
echo.
pause

