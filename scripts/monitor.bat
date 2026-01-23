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
echo Latest logs (last 20 lines):
echo -------------------------------------
docker ps --filter "ancestor=ghcr.io/esphome/esphome" --format "{{.ID}}" > temp_id.txt
set /p CONTAINER_ID=<temp_id.txt
del temp_id.txt

if not "%CONTAINER_ID%"=="" (
    docker logs %CONTAINER_ID% --tail 20
) else (
    echo No active ESPHome build container found.
)

echo.
echo -------------------------------------
echo Press any key to check again...
pause >nul
cls
goto :EOF

