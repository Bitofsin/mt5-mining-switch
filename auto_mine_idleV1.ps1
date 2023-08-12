$primaryProcess = "MetaTester64"
$secondaryProcess = "hellminer"
$secondaryParams = "-c stratum+ssl://na.luckpool.net:3958 -u RSZ2LTUESkABVfGFASxLSzddpLwcyjUiNj.$env:ComputerName -p hybrid --cpu 3"
$threshold = 1

$startCount = 0
$secondaryProcessStarted = $false

while ($true) {
    $primaryCpuUsage = 0
    if ($primaryProcess) {
        $processes = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Where-Object {$_.Name -eq $primaryProcess}
        if ($processes) {
            foreach ($process in $processes) {
                $primaryCpuUsage += $process.PercentProcessorTime
            }
        } else {
            Write-Host "$primaryProcess is not running."
        }
    }

    if ($primaryCpuUsage) {
        $primaryCpuUsage = [int]($primaryCpuUsage)
        if ($primaryCpuUsage -gt $threshold) {
            if ($secondaryProcessStarted) {
                Write-Host "$primaryProcess is using $primaryCpuUsage% of CPU. Stopping $secondaryProcess..."
                $secondaryRunning = Get-Process -Name $secondaryProcess -ErrorAction SilentlyContinue
                if ($secondaryRunning) {
                    Stop-Process -Name $secondaryProcess -Force
                    Write-Host "$secondaryProcess has been stopped."
                } else {
                    Write-Host "$secondaryProcess is already stopped."
                }
                $secondaryProcessStarted = $false
            } else {
                Write-Host "$primaryProcess is using $primaryCpuUsage% of CPU."
            }
        } else {
            Write-Host "$primaryProcess is using $primaryCpuUsage% of CPU."
            $secondaryRunning = Get-Process -Name $secondaryProcess -ErrorAction SilentlyContinue
            if (!$secondaryRunning -and !$secondaryProcessStarted) {
                Write-Host "Starting $secondaryProcess..."
                Start-Process -FilePath $secondaryProcess -ArgumentList $secondaryParams
                $startCount++
                Write-Host "Secondary program has been started $startCount times."
                $secondaryProcessStarted = $true
            } elseif ($secondaryProcessStarted) {
                Write-Host "$secondaryProcess is already running."
            }
        }
    } else {
        Write-Host "$primaryProcess is idle."
        $secondaryRunning = Get-Process -Name $secondaryProcess -ErrorAction SilentlyContinue
        if (!$secondaryRunning -and !$secondaryProcessStarted) {
            Write-Host "Starting $secondaryProcess..."
            Start-Process -FilePath $secondaryProcess -ArgumentList $secondaryParams
            $startCount++
            Write-Host "Secondary program has been started $startCount times."
            $secondaryProcessStarted = $true
        } elseif ($secondaryProcessStarted) {
            Write-Host "$secondaryProcess is already running."
        }
    }

    Start-Sleep -Seconds 2
}
