@echo off
REM Prompt the user for the desired database name
set /p DB_NAME=Enter the database name: 

REM Create MySQL database
call create_db.bat %DB_NAME%

REM Start Django server (with the specified database name)
start "Django server" cmd /k call start_django.bat %DB_NAME%

REM Start Vue server (in a new command prompt window)
start "Vue server" cmd /k call start_vue.bat

REM Prompt the user to stop the servers and delete the database
echo Press any key to stop the servers and delete the database...
pause >nul

REM Stop the servers
call stop_servers.bat

REM Delete the database
call delete_db.bat %DB_NAME%
