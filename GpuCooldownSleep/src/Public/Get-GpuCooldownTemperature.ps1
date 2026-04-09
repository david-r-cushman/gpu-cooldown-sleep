function Get-GpuCooldownTemperature {
<#
.SYNOPSIS
    Returns the current temperature for a supported GPU device.

.DESCRIPTION
    Resolves a supported GPU device either from pipeline input or by `DeviceId`
    and queries the corresponding provider integration for the current GPU
    temperature. If no device is specified and exactly one supported device is
    discoverable, that device is selected automatically.

.PARAMETER InputObject
    A GPU device object previously returned by `Get-GpuCooldownDevice`.

.PARAMETER DeviceId
    The module-level device identifier for the GPU to query.

.PARAMETER Name
    The friendly GPU name to query.

.EXAMPLE
    Get-GpuCooldownTemperature

    Returns the current temperature when exactly one supported GPU is available.

.EXAMPLE
    Get-GpuCooldownDevice | Get-GpuCooldownTemperature

    Returns the current temperature for each supplied GPU device.

.EXAMPLE
    Get-GpuCooldownTemperature -DeviceId 'nvidia:00000000:01:00.0'

    Returns the current temperature for the specified device.

.EXAMPLE
    Get-GpuCooldownTemperature -Name 'NVIDIA GeForce RTX 2070 SUPER'

    Returns the current temperature for the specified GPU by friendly device name.

.OUTPUTS
    PSCustomObject
#>
    [CmdletBinding(DefaultParameterSetName = 'Auto')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [ValidateNotNull()]
        [psobject]$InputObject,

        [Parameter(Mandatory = $true, ParameterSetName = 'DeviceId')]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    process {
        Assert-GpuCooldownMonitoringSupport

        $resolveParameters = @{}
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            $resolveParameters.InputObject = $InputObject
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'DeviceId') {
            $resolveParameters.DeviceId = $DeviceId
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Name') {
            $resolveParameters.Name = $Name
        }

        $device = Resolve-GpuCooldownDevice @resolveParameters
        Write-GpuCooldownVerboseEvent -EventName 'TemperatureQueryStart' -Device $device -Message 'Querying current GPU temperature.'

        switch ($device.Provider) {
            'Nvidia' {
                $temperatureReading = Get-NvidiaGpuCooldownTemperature -Device $device
                Write-GpuCooldownVerboseEvent -EventName 'TemperatureQueryComplete' -Device $device -Message ("Current temperature is {0}C." -f $temperatureReading.TemperatureCelsius)
                $temperatureReading
            }
            default {
                throw "Provider '$($device.Provider)' is not supported for temperature retrieval."
            }
        }
    }
}
