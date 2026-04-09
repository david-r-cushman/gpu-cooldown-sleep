function New-GpuCooldownSleepResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]$WaitResult,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Requested', 'Skipped', 'NotAttempted')]
        [string]$SleepAction
    )

    [pscustomobject]@{
        Provider                = $WaitResult.Provider
        Vendor                  = $WaitResult.Vendor
        Name                    = $WaitResult.Name
        DeviceId                = $WaitResult.DeviceId
        ProviderDeviceId        = $WaitResult.ProviderDeviceId
        PciBusId                = $WaitResult.PciBusId
        TargetTemperature       = $WaitResult.TargetTemperature
        FinalTemperatureCelsius = $WaitResult.FinalTemperatureCelsius
        Status                  = $WaitResult.Status
        SleepAction             = $SleepAction
        StartedAt               = $WaitResult.StartedAt
        CompletedAt             = $WaitResult.CompletedAt
        DurationSeconds         = $WaitResult.DurationSeconds
    }
}
