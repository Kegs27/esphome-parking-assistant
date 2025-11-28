@echo off
REM ESPHome logs - bekijk realtime logs van je device

cd /d "%~dp0.."
docker run --rm --net=host -v "%cd%":/config ghcr.io/esphome/esphome logs esphome-parking-assistant.yaml

