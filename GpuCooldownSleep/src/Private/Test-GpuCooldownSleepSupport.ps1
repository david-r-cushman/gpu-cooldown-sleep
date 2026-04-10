function Test-GpuCooldownSleepSupport {
    [CmdletBinding()]
    param()

    if (-not $IsWindows) {
        return [pscustomobject]@{
            IsSupported = $false
            IsWindows   = $false
            Message     = 'System sleep is only supported on Windows for this module.'
        }
    }

    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        return [pscustomobject]@{
            IsSupported = $true
            IsWindows   = $true
            Message     = 'System sleep APIs are available.'
        }
    }
    catch {
        return [pscustomobject]@{
            IsSupported = $false
            IsWindows   = $true
            Message     = "System.Windows.Forms could not be loaded. $($_.Exception.Message)"
        }
    }
}
