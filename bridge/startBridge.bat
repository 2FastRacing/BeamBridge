@echo off
TITLE BeamMP RCON Bridge
cd /d "%~dp0bridge"
echo Starting BeamMP RCON Bridge...
node rcon-bridge.js
pause
