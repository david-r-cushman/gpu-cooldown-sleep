function Get-GpuCooldownDeviceDisplayName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]$Device
    )

    '{0} [{1}]' -f $Device.Name, $Device.DeviceId
}
