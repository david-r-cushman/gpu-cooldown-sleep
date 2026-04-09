function Get-SupportedGpuCooldownDevicesSafely {
    [CmdletBinding()]
    param()

    try {
        return @(Get-GpuCooldownDeviceInternal)
    }
    catch {
        Write-Verbose "GPU device discovery failed during support check. $($_.Exception.Message)"
        return @()
    }
}
