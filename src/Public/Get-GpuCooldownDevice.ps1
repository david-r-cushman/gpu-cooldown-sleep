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

    $providerChecks = Get-GpuCooldownProviderSupportStatus
    if (-not $providerChecks.IsProviderAvailable) {
        Write-GpuCooldownVerboseEvent -EventName 'ProviderUnavailable' -Message $providerChecks.Message
        return @()
    }

    $supportedProviders = @(
        @{
            Name    = 'Nvidia'
            Command = { Get-NvidiaGpuCooldownDevice }
        }
    )

    if ($PSBoundParameters.ContainsKey('Provider')) {
        $supportedProviders = $supportedProviders | Where-Object { $_.Name -eq $Provider }
        Write-GpuCooldownVerboseEvent -EventName 'DiscoveryScope' -Message "Restricting GPU discovery to provider '$Provider'."
    }

    $discoveredDevices = [System.Collections.Generic.List[object]]::new()

    foreach ($supportedProvider in $supportedProviders) {
        $providerDevices = & $supportedProvider.Command
        foreach ($device in $providerDevices) {
            $null = $discoveredDevices.Add($device)
        }
    }

    $supportedDeviceCount = @($discoveredDevices).Count

    foreach ($device in $discoveredDevices) {
        $device.IsSelectedByDefault = ($supportedDeviceCount -eq 1)
        Write-GpuCooldownVerboseEvent -EventName 'DeviceDiscovered' -Device $device -Message 'Supported GPU device discovered.'
        $device
    }
}
