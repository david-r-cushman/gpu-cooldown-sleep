function Write-GpuCooldownVerboseEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EventName,

        [Parameter()]
        [psobject]$Device,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    $prefix = '[{0}]' -f $EventName
    if ($null -ne $Device) {
        $deviceLabel = Get-GpuCooldownDeviceDisplayName -Device $Device
        Write-Verbose ('{0} {1} :: {2}' -f $prefix, $deviceLabel, $Message)
        return
    }

    Write-Verbose ('{0} {1}' -f $prefix, $Message)
}
