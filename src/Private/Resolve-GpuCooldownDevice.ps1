function Resolve-GpuCooldownDevice {
    [CmdletBinding()]
    param(
        [Parameter()]
        [psobject]$InputObject,

        [Parameter()]
        [string]$DeviceId,

        [Parameter()]
        [string]$Name
    )

    if ($PSBoundParameters.ContainsKey('InputObject')) {
        if ([string]::IsNullOrWhiteSpace($InputObject.DeviceId)) {
            throw 'InputObject does not contain a valid DeviceId property.'
        }

        return $InputObject
    }

    if ($PSBoundParameters.ContainsKey('DeviceId')) {
        $matchingDevice = @(Get-GpuCooldownDevice | Where-Object { $_.DeviceId -eq $DeviceId })
        if ($matchingDevice.Count -eq 0) {
            throw "No supported GPU device was found for DeviceId '$DeviceId'."
        }

        return $matchingDevice[0]
    }

    if ($PSBoundParameters.ContainsKey('Name')) {
        $matchingDevice = @(Get-GpuCooldownDevice | Where-Object { $_.Name -eq $Name })
        if ($matchingDevice.Count -eq 0) {
            throw "No supported GPU device was found for Name '$Name'."
        }

        if ($matchingDevice.Count -gt 1) {
            throw "Multiple supported GPU devices were found for Name '$Name'. Use -DeviceId for a precise selection."
        }

        return $matchingDevice[0]
    }

    $discoverableDevices = @(Get-GpuCooldownDevice)
    if ($discoverableDevices.Count -eq 0) {
        throw 'No supported GPU devices were discovered.'
    }

    if ($discoverableDevices.Count -gt 1) {
        throw 'Multiple supported GPU devices were discovered. Specify -DeviceId, -Name, or pipe a device from Get-GpuCooldownDevice.'
    }

    return $discoverableDevices[0]
}
