function Start-SystemSleep {
    [CmdletBinding()]
    param()

    if (-not $IsWindows) {
        throw 'System sleep is only supported on Windows for this module.'
    }

    Add-Type -AssemblyName System.Windows.Forms

    $sleepResult = [System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false)
    if (-not $sleepResult) {
        throw 'The operating system did not accept the request to enter sleep.'
    }
}
