@echo off
setlocal enabledelayedexpansion

set "primaryProcess=MetaTester64.exe"
set "secondaryProcess=hellminer.exe"
set "secondaryParams=-c stratum+ssl://na.luckpool.net:3958 -u WALLET.!ComputerName! -p hybrid --cpu 3"
set "threshold=1"

set "startCount=0"
set "stopCount=0"

:loop
set "cpuUsage="
for /f %%P in ('powershell "Get-Counter -Counter '\Process(%primaryProcess%)\% Processor Time' ^| Select-Object -ExpandProperty CounterSamples ^| Measure-Object -Property CookedValue -Maximum ^| Select-Object -ExpandProperty Maximum"') do (
    set "cpuUsage=%%P"
)

if defined cpuUsage (
    set /a cpuUsage=!cpuUsage!  REM No need to divide by 100

    if !cpuUsage! GTR %threshold% (
        echo %primaryProcess% is using !cpuUsage!%% of CPU. Stopping %secondaryProcess%...
        taskkill /f /im "!secondaryProcess!" >nul 2>&1
        set /a stopCount+=1
        echo Secondary program has been stopped !stopCount! times.
    ) else (
        echo %primaryProcess% is using !cpuUsage!%% of CPU.
        tasklist /fi "imagename eq !secondaryProcess!" | find /i "!secondaryProcess!" >nul
        if errorlevel 1 (
            echo Starting !secondaryProcess!...
            start "" "!secondaryProcess!" %secondaryParams%
            set /a startCount+=1
            echo Secondary program has been started !startCount! times.
        ) else (
            echo !secondaryProcess! is already running.
        )
    )
) else (
    REM Assume process is idle when CPU usage is not available
    echo %primaryProcess% is idle.
    tasklist /fi "imagename eq !secondaryProcess!" | find /i "!secondaryProcess!" >nul
    if errorlevel 1 (
        echo Starting !secondaryProcess!...
        start "" "!secondaryProcess!" %secondaryParams%
        set /a startCount+=1
        echo Secondary program has been started !startCount! times.
    ) else (
        echo !secondaryProcess! is already running.
    )
)

timeout /t 2 >nul
goto :loop
