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
        $matchingDevice = @(Get-GpuCooldownDeviceInternal | Where-Object { $_.DeviceId -eq $DeviceId })
        if ($matchingDevice.Count -eq 0) {
            throw "No supported GPU device was found for DeviceId '$DeviceId'."
        }

        $selectedDevice = $matchingDevice[0]
        Write-GpuCooldownVerboseEvent -EventName 'DeviceSelected' -Device $selectedDevice -Message 'Selected GPU device by DeviceId.'
        return $selectedDevice
    }

    if ($PSBoundParameters.ContainsKey('Name')) {
        $matchingDevice = @(Get-GpuCooldownDeviceInternal | Where-Object { $_.Name -eq $Name })
        if ($matchingDevice.Count -eq 0) {
            throw "No supported GPU device was found for Name '$Name'."
        }

        if ($matchingDevice.Count -gt 1) {
            throw "Multiple supported GPU devices were found for Name '$Name'. Use -DeviceId for a precise selection."
        }

        $selectedDevice = $matchingDevice[0]
        Write-GpuCooldownVerboseEvent -EventName 'DeviceSelected' -Device $selectedDevice -Message 'Selected GPU device by friendly name.'
        return $selectedDevice
    }

    $discoverableDevices = @(Get-GpuCooldownDeviceInternal)
    if ($discoverableDevices.Count -eq 0) {
        throw 'No supported GPU devices were discovered.'
    }

    if ($discoverableDevices.Count -gt 1) {
        throw 'Multiple supported GPU devices were discovered. Specify -DeviceId, -Name, or pipe a device from Get-GpuCooldownDevice.'
    }

    Write-GpuCooldownVerboseEvent -EventName 'DeviceSelected' -Device $discoverableDevices[0] -Message 'Selected the only supported GPU device.'
    return $discoverableDevices[0]
}
