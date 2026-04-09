function Test-GpuCooldownSupport {
<#
.SYNOPSIS
    Reports whether the current environment supports GPU cooldown monitoring and sleep workflows.

.DESCRIPTION
    Evaluates the current host environment, provider dependencies, and device discovery
    state to determine whether the module can monitor GPU temperature and request system
    sleep. The command returns a structured summary of the checks instead of throwing
    unless an unexpected internal failure occurs.

.EXAMPLE
    Test-GpuCooldownSupport

    Returns a support summary for the current environment.

.OUTPUTS
    PSCustomObject
#>
    [CmdletBinding()]
    param()

    $providerChecks = Get-GpuCooldownProviderSupportStatus
    $supportedDevices = Get-SupportedGpuCooldownDevicesSafely

    $sleepSupport = Test-GpuCooldownSleepSupport
    $keepAwakeSupport = Test-GpuCooldownKeepAwakeSupport

    [pscustomobject]@{
        IsSupported              = ($providerChecks.IsProviderAvailable -and $supportedDevices.Count -gt 0)
        IsWindows                = $sleepSupport.IsWindows
        SleepSupported           = $sleepSupport.IsSupported
        KeepAwakeSupported       = $keepAwakeSupport.IsSupported
        ProviderAvailable        = $providerChecks.IsProviderAvailable
        ProviderName             = $providerChecks.ProviderName
        ProviderCommand          = $providerChecks.ProviderCommand
        SupportedDeviceCount     = $supportedDevices.Count
        SupportedDeviceNames     = @($supportedDevices.Name)
        ProviderStatusMessage    = $providerChecks.Message
        SleepStatusMessage       = $sleepSupport.Message
        KeepAwakeStatusMessage   = $keepAwakeSupport.Message
    }
}
