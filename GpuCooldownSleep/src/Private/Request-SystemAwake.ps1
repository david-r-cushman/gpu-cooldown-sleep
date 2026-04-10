function Request-SystemAwake {
    [CmdletBinding()]
    param()

    Add-SystemAwakeInteropType

    $flags = [SystemAwakeInterop]::ES_CONTINUOUS -bor [SystemAwakeInterop]::ES_SYSTEM_REQUIRED
    $previousState = [SystemAwakeInterop]::SetThreadExecutionState($flags)
    if ($previousState -eq 0) {
        throw 'Failed to request that the system remain awake during cooldown monitoring.'
    }

    [pscustomobject]@{
        PreviousState = [uint32]$previousState
    }
}
