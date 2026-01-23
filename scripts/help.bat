@echo off
cls
echo =====================================
echo ESPHome Parking Assistant - HELP
echo =====================================
echo.
echo 📁 PROJECT STRUCTURE
echo ────────────────────────────────────
echo   esphome-parking-assistant.yaml  - Main configuration
echo   secrets.yaml                    - WiFi credentials
echo   scripts/                        - Build scripts
echo.
echo 🛠️  AVAILABLE SCRIPTS
echo ────────────────────────────────────
echo   Main directory (shortcuts):
echo     build.bat       - Compile firmware
echo     upload.bat      - Upload via WiFi
echo     logs.bat        - View logs
echo.
echo   scripts/ directory (all options):
echo     build.bat           - Compile firmware
echo     build-verbose.bat   - Build with verbose output
echo     upload.bat          - Upload via WiFi (OTA)
echo     logs.bat            - View realtime logs
echo     validate.bat        - Validate YAML
echo     clean.bat           - Clear build cache
echo     monitor.bat         - Monitor build status
echo.
echo ⏱️  BUILD TIMES
echo ────────────────────────────────────
echo   First build:   8-10 minutes  (download tools)
echo   Next builds:   1-3 minutes   (uses cache)
echo.
echo 🚀 QUICK START
echo ────────────────────────────────────
echo   1. Fill in secrets.yaml with WiFi credentials
echo   2. Run: build.bat
echo   3. Run: upload.bat
echo   4. Run: logs.bat (to check)
echo.
echo 📚 DOCUMENTATION
echo ────────────────────────────────────
echo   README.md              - Complete documentation
echo.
echo 🔧 TROUBLESHOOTING
echo ────────────────────────────────────
echo   Build problems?      → Run: scripts\clean.bat
echo   Sensor not working?  → Check README.md hardware section
echo   WiFi errors?         → Check secrets.yaml
echo.
echo 💡 TIP: Open README.md for complete instructions!
echo.
pause

