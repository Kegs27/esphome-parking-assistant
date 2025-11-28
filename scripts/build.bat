@echo off
REM ESPHome build script - compile only
REM Met persistent cache volume voor snellere en betrouwbaardere builds

cd /d "%~dp0.."
docker run --rm -v "%cd%":/config -v esphome-cache:/cache ghcr.io/esphome/esphome compile esphome-parking-assistant.yaml

