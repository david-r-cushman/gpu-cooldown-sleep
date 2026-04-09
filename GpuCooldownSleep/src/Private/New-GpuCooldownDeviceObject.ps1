function New-GpuCooldownDeviceObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Provider,

        [Parameter(Mandatory = $true)]
        [string]$Vendor,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$ProviderDeviceId
    )

    [pscustomobject]@{
        Provider            = $Provider
        Vendor              = $Vendor
        Name                = $Name
        DeviceId            = '{0}:{1}' -f $Provider.ToLowerInvariant(), $ProviderDeviceId
        ProviderDeviceId    = $ProviderDeviceId
        PciBusId            = $ProviderDeviceId
        IsSupported         = $true
        IsSelectedByDefault = $false
    }
}
