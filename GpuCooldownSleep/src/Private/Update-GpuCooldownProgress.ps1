function Update-GpuCooldownProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]$Device,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]$TemperatureReading,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 200)]
        [int]$TargetTemperature,

        [Parameter(Mandatory = $true)]
        [datetime]$StartedAt,

        [Parameter(Mandatory = $true)]
        [datetime]$TimeoutAt
    )

    $totalDurationSeconds = [math]::Max((New-TimeSpan -Start $StartedAt -End $TimeoutAt).TotalSeconds, 1)
    $elapsedSeconds = (New-TimeSpan -Start $StartedAt -End (Get-GpuCooldownNow)).TotalSeconds
    $percentComplete = [math]::Min([math]::Round(($elapsedSeconds / $totalDurationSeconds) * 100, 0), 99)

    $status = '{0}C current, target {1}C, timeout at {2}' -f $TemperatureReading.TemperatureCelsius, $TargetTemperature, $TimeoutAt.ToString('HH:mm:ss')

    Write-Progress -Id 1 -Activity ("Cooling GPU: {0}" -f $Device.Name) -Status $status -PercentComplete $percentComplete
}
