@echo off
REM ESPHome build script - compile only
REM With persistent cache volume for faster and more reliable builds

cd /d "%~dp0.."
docker run --rm -v "%cd%":/config -v esphome-cache:/cache ghcr.io/esphome/esphome compile esphome-parking-assistant.yaml

