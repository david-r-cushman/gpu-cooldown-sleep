function New-GpuCooldownWaitResultObject {
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
        [datetime]$CompletedAt,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TargetReached', 'TimedOut')]
        [string]$Status
    )

    [pscustomobject]@{
        Provider               = $Device.Provider
        Vendor                 = $Device.Vendor
        Name                   = $Device.Name
        DeviceId               = $Device.DeviceId
        ProviderDeviceId       = $Device.ProviderDeviceId
        PciBusId               = $Device.PciBusId
        TargetTemperature      = $TargetTemperature
        FinalTemperatureCelsius = $TemperatureReading.TemperatureCelsius
        Status                 = $Status
        StartedAt              = $StartedAt
        CompletedAt            = $CompletedAt
        DurationSeconds        = [math]::Round(($CompletedAt - $StartedAt).TotalSeconds, 2)
    }
}
