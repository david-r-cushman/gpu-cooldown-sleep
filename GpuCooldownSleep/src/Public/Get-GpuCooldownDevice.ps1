function Get-GpuCooldownDevice {
<#
.SYNOPSIS
    Returns GPU devices that are supported by the module's current telemetry providers.

.DESCRIPTION
    Queries the currently implemented provider integrations and returns a normalized
    object shape for each supported GPU device. The initial implementation is
    NVIDIA-first and uses `nvidia-smi` when available, but the output contract is
    vendor-neutral so additional providers can be added later without changing the
    public command shape.

.PARAMETER Provider
    Limits discovery to a specific provider.

.EXAMPLE
    Get-GpuCooldownDevice

    Returns all supported GPU devices currently discoverable by the module.

.EXAMPLE
    Get-GpuCooldownDevice -Provider Nvidia

    Returns only devices discovered through the NVIDIA provider integration.

.OUTPUTS
    PSCustomObject
#>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Nvidia')]
        [string]$Provider
    )

    $internalParameters = @{
        EmitVerboseEvents = $true
    }

    if ($PSBoundParameters.ContainsKey('Provider')) {
        $internalParameters.Provider = $Provider
    }

    Get-GpuCooldownDeviceInternal @internalParameters
}
