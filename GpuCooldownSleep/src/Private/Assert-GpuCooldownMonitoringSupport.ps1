function Assert-GpuCooldownMonitoringSupport {
    [CmdletBinding()]
    param()

    $providerChecks = Get-GpuCooldownProviderSupportStatus
    if (-not $providerChecks.IsProviderAvailable) {
        throw $providerChecks.Message
    }

    $devices = Get-SupportedGpuCooldownDevicesSafely
    if ($devices.Count -eq 0) {
        throw 'No supported GPU devices were discovered in the current environment.'
    }
}
