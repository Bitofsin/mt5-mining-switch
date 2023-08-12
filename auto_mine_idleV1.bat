@echo off

set "primaryProcess=MetaTester64"
set "secondaryProcess=hellminer"
set "secondaryParams=-c stratum+ssl://na.luckpool.net:3958 -u RSZ2LTUESkABVfGFASxLSzddpLwcyjUiNj.%ComputerName% -p hybrid --cpu 3"
set "threshold=0.5"

set "startCount=0"
set "secondaryProcessStarted=false"

:loop
set "primaryCpuUsage="
for /f %%P in ('powershell "Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Where-Object {$_.Name -eq '%primaryProcess%'} | Measure-Object -Property PercentProcessorTime -Sum | Select-Object -ExpandProperty Sum"') do (
    set "primaryCpuUsage=%%P"
)

if defined primaryCpuUsage (
    set /a primaryCpuUsage=primaryCpuUsage
    if %primaryCpuUsage% GTR %threshold% (
        if %secondaryProcessStarted% == true (
            echo %primaryProcess% is using %primaryCpuUsage%%% of CPU. Stopping %secondaryProcess%...
            powershell "Get-Process -Name '%secondaryProcess%' | Stop-Process -Force"
            set "secondaryProcessStarted=false"
        ) else (
            echo %primaryProcess% is using %primaryCpuUsage%%% of CPU.
        )
    ) else (
        echo %primaryProcess% is using %primaryCpuUsage%%% of CPU.
        tasklist /fi "imagename eq %secondaryProcess%" | find /i "%secondaryProcess%" >nul
        if errorlevel 1 (
            if not %secondaryProcessStarted% == true (
                echo Starting %secondaryProcess%...
                start "" "%secondaryProcess%" %secondaryParams%
                set /a startCount+=1
                echo Secondary program has been started %startCount% times.
                set "secondaryProcessStarted=true"
            )
        ) else (
            echo %secondaryProcess% is already running.
        )
    )
) else (
    echo %primaryProcess% is idle.
    tasklist /fi "imagename eq %secondaryProcess%" | find /i "%secondaryProcess%" >nul
    if errorlevel 1 (
        if not %secondaryProcessStarted% == true (
            echo Starting %secondaryProcess%...
            start "" "%secondaryProcess%" %secondaryParams%
            set /a startCount+=1
            echo Secondary program has been started %startCount% times.
            set "secondaryProcessStarted=true"
        )
    ) else (
        echo %secondaryProcess% is already running.
    )
)

timeout /t 2 >nul
goto :loop
