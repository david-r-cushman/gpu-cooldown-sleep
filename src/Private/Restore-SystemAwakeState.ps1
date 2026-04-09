function Restore-SystemAwakeState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]$Token
    )

    Add-SystemAwakeInteropType

    $restoreResult = [SystemAwakeInterop]::SetThreadExecutionState([SystemAwakeInterop]::ES_CONTINUOUS)
    if ($restoreResult -eq 0) {
        throw 'Failed to restore normal system sleep behavior after cooldown monitoring.'
    }
}
