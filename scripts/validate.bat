@echo off
REM ESPHome validate - check je YAML configuratie op fouten

cd /d "%~dp0.."
docker run --rm -v "%cd%":/config -v esphome-cache:/cache ghcr.io/esphome/esphome config esphome-parking-assistant.yaml

