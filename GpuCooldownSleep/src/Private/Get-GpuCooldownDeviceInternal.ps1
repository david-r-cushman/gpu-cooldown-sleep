function Get-GpuCooldownDeviceInternal {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Nvidia')]
        [string]$Provider,

        [Parameter()]
        [switch]$EmitVerboseEvents
    )

    $providerChecks = Get-GpuCooldownProviderSupportStatus
    if (-not $providerChecks.IsProviderAvailable) {
        if ($EmitVerboseEvents.IsPresent) {
            Write-GpuCooldownVerboseEvent -EventName 'ProviderUnavailable' -Message $providerChecks.Message
        }
        else {
            Write-Verbose $providerChecks.Message
        }
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
        if ($EmitVerboseEvents.IsPresent) {
            Write-GpuCooldownVerboseEvent -EventName 'DiscoveryScope' -Message "Restricting GPU discovery to provider '$Provider'."
        }
        else {
            Write-Verbose "Restricting GPU discovery to provider '$Provider'."
        }
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
        if ($EmitVerboseEvents.IsPresent) {
            Write-GpuCooldownVerboseEvent -EventName 'DeviceDiscovered' -Device $device -Message 'Supported GPU device discovered.'
        }
        $device
    }
}
