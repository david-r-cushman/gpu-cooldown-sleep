function Start-GpuCooldownSleep {
<#
.SYNOPSIS
    Waits for GPU cooldown and then puts the system to sleep.

.DESCRIPTION
    Monitors GPU temperature until the target threshold is reached or a timeout occurs.
    While the wait loop is active, the command can temporarily request that the system
    remain awake so cooldown monitoring is not interrupted by normal sleep behavior. If
    the target is reached, the command initiates system sleep. If the timeout is
    reached, it returns the monitoring result without changing system power state.

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

.PARAMETER PreventSystemSleep
    Requests that the operating system remain awake while cooldown monitoring is active.

.EXAMPLE
    Start-GpuCooldownSleep -TargetTemperature 40 -WhatIf

    Shows what would happen if the system reached the target temperature and sleep were initiated.

.EXAMPLE
    Get-GpuCooldownDevice | Start-GpuCooldownSleep -TargetTemperature 38 -PreventSystemSleep

    Monitors the supplied GPU device, requests that the system remain awake during the
    wait period, and puts the system to sleep if the target temperature is reached.

.OUTPUTS
    PSCustomObject
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Auto')]
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
        [switch]$PreventSystemSleep
    )

    process {
        $waitParameters = @{
            TargetTemperature   = $TargetTemperature
            PollIntervalSeconds = $PollIntervalSeconds
            TimeoutMinutes      = $TimeoutMinutes
            Verbose             = $VerbosePreference -ne 'SilentlyContinue'
        }

        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            $waitParameters.InputObject = $InputObject
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'DeviceId') {
            $waitParameters.DeviceId = $DeviceId
        }

        $keepAwakeToken = $null

        try {
            if ($PreventSystemSleep.IsPresent) {
                $keepAwakeToken = Request-SystemAwake
            }

            $waitResult = Wait-GpuCooldown @waitParameters

            if ($waitResult.Status -ne 'TargetReached') {
                return $waitResult
            }

            if ($PSCmdlet.ShouldProcess($waitResult.Name, "Put system to sleep after GPU cooldown reached ${TargetTemperature}C")) {
                Start-SystemSleep
            }

            return $waitResult
        }
        finally {
            if ($null -ne $keepAwakeToken) {
                Restore-SystemAwakeState -Token $keepAwakeToken
            }
        }
    }
}
