# script.ps1
$primaryProcess = "MetaTester64.exe"
$secondaryProcess = "hellminer.exe"
$baseParams = "-c stratum+ssl://na.luckpool.net:3958 -u RSZ2LTUESkABVfGFASxLSzddpLwcyjUiNj.$env:ComputerName -p hybrid --cpu"
$threshold = 1
$maxTemperature = 60
$maxRamUsageMB = 200  # Set the maximum RAM usage in megabytes (e.g., 200 MB)
$minCores = 1
$maxCores = [Math]::Max((Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors - 1, $minCores)
$secondaryProcessStarted = $false

while ($true) {
    $primaryCpuUsage = (Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.Name -eq $primaryProcess } | Measure-Object -Property PercentProcessorTime -Sum).Sum

    $primaryRamUsage = (Get-WmiObject Win32_Process | Where-Object { $_.Name -eq $primaryProcess } | Measure-Object -Property WorkingSetSize -Sum).Sum / 1MB

    $temperature = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" | ForEach-Object { $_.CurrentTemperature / 10 - 273.15 }

    if ($primaryCpuUsage -gt $threshold -or $primaryRamUsage -gt $maxRamUsageMB) {
        if ($secondaryProcessStarted) {
            Write-Host "$primaryProcess is using $primaryCpuUsage% CPU and $($primaryRamUsage.ToString('F2')) MB RAM. Stopping $secondaryProcess..."
            Stop-Process -Name $secondaryProcess -Force
            $secondaryProcessStarted = $false
        }
        else {
            Write-Host "$primaryProcess is using $primaryCpuUsage% CPU and $($primaryRamUsage.ToString('F2')) MB RAM."
        }
    }
    else {
        Write-Host "$primaryProcess is using $primaryCpuUsage% CPU and $($primaryRamUsage.ToString('F2')) MB RAM."

        if ($temperature -ge $maxTemperature) {
            $newCoreCount = [Math]::Max($minCores, $maxCores - 1)
            if ($secondaryProcessStarted -eq $false -or $newCoreCount -ne $maxCores) {
                Write-Host "Temperature is high ($temperature°C). Starting $secondaryProcess with $newCoreCount cores..."
                Stop-Process -Name $secondaryProcess -Force
                Start-Process -FilePath $secondaryProcess -ArgumentList ($baseParams + " $newCoreCount")
                $secondaryProcessStarted = $true
            }
        }
        elseif ($temperature -lt $maxTemperature) {
            $newCoreCount = [Math]::Min($maxCores, $maxCores - 1 + [Math]::Round(($maxTemperature - $temperature) / ($maxTemperature / ($maxCores - 1))))
            if ($secondaryProcessStarted -eq $false -or $newCoreCount -ne $maxCores) {
                Write-Host "Temperature is lower ($temperature°C). Adjusting $secondaryProcess cores to $newCoreCount..."
                Stop-Process -Name $secondaryProcess -Force
                Start-Process -FilePath $secondaryProcess -ArgumentList ($baseParams + " $newCoreCount")
                $secondaryProcessStarted = $true
            }
        }
    }

    Start-Sleep -Seconds 2
}
