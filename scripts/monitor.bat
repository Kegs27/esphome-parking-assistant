@echo off
cd /d "%~dp0.."

echo =====================================
echo Docker Build Monitor
echo =====================================
echo.
echo Checking if build is still running...
echo.

docker ps --filter "ancestor=ghcr.io/esphome/esphome" --format "table {{.ID}}\t{{.Status}}\t{{.RunningFor}}"

echo.
echo Latest logs (laatste 20 regels):
echo -------------------------------------
docker ps --filter "ancestor=ghcr.io/esphome/esphome" --format "{{.ID}}" > temp_id.txt
set /p CONTAINER_ID=<temp_id.txt
del temp_id.txt

if not "%CONTAINER_ID%"=="" (
    docker logs %CONTAINER_ID% --tail 20
) else (
    echo Geen actieve ESPHome build container gevonden.
)

echo.
echo -------------------------------------
echo Druk op een toets om opnieuw te checken...
pause >nul
cls
goto :EOF

