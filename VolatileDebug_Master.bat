@REM @echo off
@REM Prompt the user for the desired database name
set /p DB_NAME=Enter the database name: 

@REM Create MySQL database
call "BatchFile\Create_DB_MySQL.bat" %DB_NAME%

@REM Start Django server (with the specified database name)
start "Django server" cmd /k call "BatchFile\RunServer_Django.bat" %DB_NAME%

@REM Start Vue server (in a new command prompt window)
start "Vue server Volatile" cmd /k call "BatchFile\RunServer_Vue.bat"

@REM Start chrome http://localhost:8080/
@REM start chrome http://localhost:8000/

@REM Prompt the user to stop the servers and delete the database
echo Press any key to stop the servers and delete the database...
pause >nul

@REM Stop the servers
@REM call "BatchFile\StopServer.bat"

@REM Delete the database
call "BatchFile\Delete_DB.bat" %DB_NAME%
