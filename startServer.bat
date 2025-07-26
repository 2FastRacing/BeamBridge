@echo off

:: Set the script's title
TITLE BeamMP - Development02 (Wrapped with Node.js)

:: Clear the screen for better readability
cls

:start

:: Display a message indicating the server start process
echo Starting BeamMP wrapper...

:: Wait briefly before starting
timeout /t 1 >nul

:: Start wrapper.js using Node.js
node wrapper.js

:: Check if Node.js wrapper is still running
tasklist | findstr /i "node.exe"

:: Perform backup operations
CALL :BackupLogs

:: Display a message indicating server restart
echo.
echo Restarting wrapper...
echo.

:: Return to the beginning of the script
goto start

:: ----------------------- SUBROUTINES -----------------------

:BackupLogs
    :: Backup the server log with a timestamp
    echo ---------------------SAVING SERVERLOG---------------------
    set CurrentTimestamp=%date:~10,4%-%date:~7,2%-%date:~4,2%_%time:~0,2%-%time:~3,2%
    
    :: Fix for leading space in hours
    set CurrentTimestamp=%CurrentTimestamp: =0%

    :: Rename and move logs
    ren *.log Serverlog_%CurrentTimestamp%.log
    robocopy . .\logs Serverlog_*.log /r:1 /mt /z /is
    del Serverlog_*.log /q /f

    echo ---------------------SERVERLOG SAVED---------------------
    exit /b

:: --------------------- END OF SUBROUTINES ---------------------
