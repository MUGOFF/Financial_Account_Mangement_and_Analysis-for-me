@echo off

REM Terminate the Django server
taskkill /f /im python.exe /fi "WindowTitle eq Django server"

REM Terminate the Vue.js server (assuming it's running with npm)
taskkill /f /im node.exe /fi "WindowTitle eq Vue.js development server"

echo Servers have been terminated.
