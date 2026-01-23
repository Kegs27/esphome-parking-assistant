@echo off
REM ESPHome validate - check your YAML configuration for errors

cd /d "%~dp0.."
docker run --rm -v "%cd%":/config -v esphome-cache:/cache ghcr.io/esphome/esphome config esphome-parking-assistant.yaml

