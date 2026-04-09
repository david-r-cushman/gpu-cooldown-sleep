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

.EXAMPLE
    Get-GpuCooldownTemperature

    Returns the current temperature when exactly one supported GPU is available.

.EXAMPLE
    Get-GpuCooldownDevice | Get-GpuCooldownTemperature

    Returns the current temperature for each supplied GPU device.

.EXAMPLE
    Get-GpuCooldownTemperature -DeviceId 'nvidia:00000000:01:00.0'

    Returns the current temperature for the specified device.

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
        [string]$DeviceId
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

        switch ($device.Provider) {
            'Nvidia' {
                Get-NvidiaGpuCooldownTemperature -Device $device
            }
            default {
                throw "Provider '$($device.Provider)' is not supported for temperature retrieval."
            }
        }
    }
}
