function Restore-SystemAwakeState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]$Token
    )

    Add-SystemAwakeInteropType

    if ($null -eq $Token.PreviousState) {
        throw 'Token does not contain a PreviousState value required to restore system sleep behavior.'
    }

    $restoreResult = [SystemAwakeInterop]::SetThreadExecutionState([uint32]$Token.PreviousState)
    if ($restoreResult -eq 0) {
        throw 'Failed to restore normal system sleep behavior after cooldown monitoring.'
    }
}
