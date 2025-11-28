@echo off
cls
echo =====================================
echo ESPHome Parking Assistant - HELP
echo =====================================
echo.
echo 📁 PROJECT STRUCTUUR
echo ────────────────────────────────────
echo   esphome-parking-assistant.yaml  - Hoofdconfiguratie
echo   secrets.yaml                    - WiFi credentials
echo   scripts/                        - Build scripts
echo   docs/                           - Documentatie
echo.
echo 🛠️  BESCHIKBARE SCRIPTS
echo ────────────────────────────────────
echo   Hoofd directory (shortcuts):
echo     build.bat       - Compileer firmware
echo     upload.bat      - Upload via WiFi
echo     logs.bat        - Bekijk logs
echo.
echo   scripts/ directory (alle opties):
echo     build.bat           - Compileer firmware
echo     build-verbose.bat   - Build met verbose output
echo     upload.bat          - Upload via WiFi (OTA)
echo     logs.bat            - Bekijk realtime logs
echo     validate.bat        - Valideer YAML
echo     clean.bat           - Wis build cache
echo     monitor.bat         - Monitor build status
echo.
echo ⏱️  BUILD TIJDEN
echo ────────────────────────────────────
echo   Eerste build:  8-10 minuten  (download tools)
echo   Volgende:      1-3 minuten   (gebruikt cache)
echo.
echo 🚀 QUICK START
echo ────────────────────────────────────
echo   1. Vul secrets.yaml in met WiFi gegevens
echo   2. Run: build.bat
echo   3. Run: upload.bat
echo   4. Run: logs.bat (om te checken)
echo.
echo 📚 DOCUMENTATIE
echo ────────────────────────────────────
echo   README.md              - Volledige documentatie
echo   docs/STATUS.md         - Build status info
echo   docs/LOKAAL-vs-HA.md  - Lokaal vs HA builds
echo   CHANGELOG.md           - Versie geschiedenis
echo.
echo 🔧 TROUBLESHOOTING
echo ────────────────────────────────────
echo   Build problemen?     → Run: scripts\clean.bat
echo   Sensor werkt niet?   → Check README.md hardware sectie
echo   WiFi errors?         → Check secrets.yaml
echo.
echo 💡 TIP: Open README.md voor complete instructies!
echo.
pause

