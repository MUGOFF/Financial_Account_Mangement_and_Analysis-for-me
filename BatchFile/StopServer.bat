@echo off

REM Terminate the Django server
taskkill /f /im python.exe /fi "WindowTitle eq Django server Volatile"

REM Terminate the Vue.js server (assuming it's running with npm)
taskkill /f /im node.exe /fi "WindowTitle eq Vue server Volatile"

echo Servers have been terminated.
