@echo off
REM ESPHome logs - view realtime logs from your device

cd /d "%~dp0.."
docker run --rm --net=host -v "%cd%":/config ghcr.io/esphome/esphome logs esphome-parking-assistant.yaml

