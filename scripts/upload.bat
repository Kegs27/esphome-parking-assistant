@echo off
REM ESPHome upload script - compile and upload via WiFi (OTA)
REM With persistent cache volume for faster builds

cd /d "%~dp0.."
docker run --rm --net=host -v "%cd%":/config -v esphome-cache:/cache ghcr.io/esphome/esphome run esphome-parking-assistant.yaml

