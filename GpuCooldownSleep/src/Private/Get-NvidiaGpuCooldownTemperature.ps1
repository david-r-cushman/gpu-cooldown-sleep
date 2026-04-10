function Get-NvidiaGpuCooldownTemperature {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]$Device
    )

    $nvidiaSmi = Get-Command -Name 'nvidia-smi' -ErrorAction SilentlyContinue
    if (-not $nvidiaSmi) {
        throw 'nvidia-smi was not found. NVIDIA temperature retrieval is unavailable.'
    }

    $queryArguments = @(
        '--query-gpu=pci.bus_id,temperature.gpu'
        '--format=csv,noheader'
    )

    try {
        $rawLines = & $nvidiaSmi.Source @queryArguments 2>$null
    }
    catch {
        throw "Failed to query NVIDIA GPU temperature via nvidia-smi. $($_.Exception.Message)"
    }

    if (-not $rawLines) {
        throw 'nvidia-smi returned no temperature data.'
    }

    $temperatureMap = @{}
    foreach ($line in $rawLines) {
        $parsedLine = ConvertFrom-NvidiaSmiTemperatureLine -InputLine $line
        $temperatureMap[$parsedLine.PciBusId] = $parsedLine.TemperatureCelsius
    }

    if (-not $temperatureMap.ContainsKey($Device.ProviderDeviceId)) {
        throw "No NVIDIA temperature reading was found for provider device '$($Device.ProviderDeviceId)'."
    }

    [pscustomobject]@{
        Provider            = $Device.Provider
        Vendor              = $Device.Vendor
        Name                = $Device.Name
        DeviceId            = $Device.DeviceId
        ProviderDeviceId    = $Device.ProviderDeviceId
        PciBusId            = $Device.PciBusId
        TemperatureCelsius  = $temperatureMap[$Device.ProviderDeviceId]
        RetrievedAt         = Get-Date
    }
}
