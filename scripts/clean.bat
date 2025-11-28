@echo off
cd /d "%~dp0.."

echo =====================================
echo ESPHome - Clean Build
echo =====================================
echo.
echo Dit script wist de lokale build cache.
echo Gebruik dit als de build vastloopt of rare errors geeft.
echo.
echo WAARSCHUWING: De volgende build duurt dan weer langer!
echo.
set /p confirm="Weet je zeker dat je wilt cleanen? (j/n): "
if /i not "%confirm%"=="j" (
    echo Geannuleerd.
    pause
    exit /b
)

echo.
echo Bezig met cleanen...

REM Clean lokale build directory
if exist ".esphome\build" (
    echo Verwijderen .esphome\build...
    rmdir /s /q ".esphome\build"
)

if exist ".esphome\platformio" (
    echo Verwijderen .esphome\platformio...
    rmdir /s /q ".esphome\platformio"
)

REM Optioneel: wis ook Docker cache volume
echo.
set /p cleanvol="Wil je ook het Docker cache volume wissen? (j/n): "
if /i "%cleanvol%"=="j" (
    echo Verwijderen Docker cache volume...
    docker volume rm esphome-cache 2>nul
    docker volume create esphome-cache
    echo Docker cache volume opnieuw aangemaakt.
)

echo.
echo =====================================
echo CLEAN VOLTOOID
echo =====================================
echo Je kunt nu build.bat opnieuw uitvoeren.
echo.
pause

