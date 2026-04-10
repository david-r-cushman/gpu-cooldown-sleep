function Start-SystemSleep {
    [CmdletBinding()]
    param()

    if (-not $IsWindows) {
        throw 'System sleep is only supported on Windows for this module.'
    }

    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    }
    catch {
        throw "Failed to load System.Windows.Forms required to request system sleep. $($_.Exception.Message)"
    }

    $sleepResult = [System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false)
    if (-not $sleepResult) {
        throw 'The operating system did not accept the request to enter sleep.'
    }
}
