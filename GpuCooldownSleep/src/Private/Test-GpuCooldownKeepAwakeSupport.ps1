function Test-GpuCooldownKeepAwakeSupport {
    [CmdletBinding()]
    param()

    if (-not $IsWindows) {
        return [pscustomobject]@{
            IsSupported = $false
            Message     = 'Keep-awake behavior is only supported on Windows for this module.'
        }
    }

    try {
        Add-SystemAwakeInteropType
        return [pscustomobject]@{
            IsSupported = $true
            Message     = 'SetThreadExecutionState interop is available.'
        }
    }
    catch {
        return [pscustomobject]@{
            IsSupported = $false
            Message     = "SetThreadExecutionState interop is unavailable. $($_.Exception.Message)"
        }
    }
}
