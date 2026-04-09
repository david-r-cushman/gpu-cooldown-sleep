function Wait-GpuCooldown {
<#
.SYNOPSIS
    Monitors GPU temperature until a target threshold is reached or a timeout occurs.

.DESCRIPTION
    Polls the current GPU temperature for a selected supported device at a configurable
    interval and returns a structured result when the target temperature is reached or
    the maximum wait time expires. This command does not change system power state. It
    exists to provide a safe orchestration layer that can be validated independently
    before sleep behavior is introduced.

.PARAMETER TargetTemperature
    The target GPU temperature in degrees Celsius.

.PARAMETER InputObject
    A GPU device object previously returned by `Get-GpuCooldownDevice`.

.PARAMETER DeviceId
    The module-level device identifier for the GPU to monitor.

.PARAMETER PollIntervalSeconds
    The number of seconds to wait between temperature checks.

.PARAMETER TimeoutMinutes
    The maximum number of minutes to wait before returning a timeout result.

.PARAMETER ShowProgress
    Displays an interactive progress view while cooldown monitoring is active.

.EXAMPLE
    Wait-GpuCooldown -TargetTemperature 40

    Waits for the single supported GPU to cool to 40C or until the timeout is reached.

.EXAMPLE
    Get-GpuCooldownDevice | Wait-GpuCooldown -TargetTemperature 38 -ShowProgress

    Waits for the supplied GPU device to reach the target temperature.

.OUTPUTS
    PSCustomObject
#>
    [CmdletBinding(DefaultParameterSetName = 'Auto')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 200)]
        [int]$TargetTemperature,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [ValidateNotNull()]
        [psobject]$InputObject,

        [Parameter(Mandatory = $true, ParameterSetName = 'DeviceId')]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter()]
        [ValidateRange(1, 3600)]
        [int]$PollIntervalSeconds = 10,

        [Parameter()]
        [ValidateRange(1, 1440)]
        [int]$TimeoutMinutes = 15,

        [Parameter()]
        [switch]$ShowProgress
    )

    process {
        $resolveParameters = @{}
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            $resolveParameters.InputObject = $InputObject
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'DeviceId') {
            $resolveParameters.DeviceId = $DeviceId
        }

        $device = Resolve-GpuCooldownDevice @resolveParameters
        $startedAt = Get-Date
        $timeoutAt = $startedAt.AddMinutes($TimeoutMinutes)

        Write-Verbose "Monitoring device '$($device.Name)' with target temperature ${TargetTemperature}C."
        Write-Verbose "Polling every $PollIntervalSeconds seconds until $timeoutAt."

        try {
            do {
                $temperatureReading = Get-GpuCooldownTemperature -InputObject $device
                $currentTime = Get-Date
                $elapsed = $currentTime - $startedAt

                if ($ShowProgress.IsPresent) {
                    Update-GpuCooldownProgress -Device $device -TemperatureReading $temperatureReading -TargetTemperature $TargetTemperature -StartedAt $startedAt -TimeoutAt $timeoutAt
                }

                if ($temperatureReading.TemperatureCelsius -le $TargetTemperature) {
                    return New-GpuCooldownWaitResultObject -Device $device -TemperatureReading $temperatureReading -TargetTemperature $TargetTemperature -StartedAt $startedAt -CompletedAt $currentTime -Status 'TargetReached'
                }

                if ($currentTime -ge $timeoutAt) {
                    return New-GpuCooldownWaitResultObject -Device $device -TemperatureReading $temperatureReading -TargetTemperature $TargetTemperature -StartedAt $startedAt -CompletedAt $currentTime -Status 'TimedOut'
                }

                Write-Verbose ("Current temperature for '{0}' is {1}C after {2:n1} seconds." -f $device.Name, $temperatureReading.TemperatureCelsius, $elapsed.TotalSeconds)
                Start-Sleep -Seconds $PollIntervalSeconds
            }
            while ($true)
        }
        finally {
            if ($ShowProgress.IsPresent) {
                Clear-GpuCooldownProgress
            }
        }
    }
}
