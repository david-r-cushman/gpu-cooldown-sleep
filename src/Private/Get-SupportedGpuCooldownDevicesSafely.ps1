function Get-SupportedGpuCooldownDevicesSafely {
    [CmdletBinding()]
    param()

    try {
        return @(Get-GpuCooldownDevice)
    }
    catch {
        Write-Verbose "GPU device discovery failed during support check. $($_.Exception.Message)"
        return @()
    }
}
