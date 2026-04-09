function Get-NvidiaGpuCooldownDevice {
    [CmdletBinding()]
    param()

    $nvidiaSmi = Get-Command -Name 'nvidia-smi' -ErrorAction SilentlyContinue
    if (-not $nvidiaSmi) {
        Write-Verbose 'nvidia-smi was not found. Skipping NVIDIA GPU discovery.'
        return @()
    }

    $queryArguments = @(
        '--query-gpu=name,pci.bus_id'
        '--format=csv,noheader'
    )

    try {
        $rawLines = & $nvidiaSmi.Source @queryArguments 2>$null
    }
    catch {
        throw "Failed to query NVIDIA GPU information via nvidia-smi. $($_.Exception.Message)"
    }

    if (-not $rawLines) {
        return @()
    }

    $devices = foreach ($line in $rawLines) {
        $parsedDevice = ConvertFrom-NvidiaSmiDeviceLine -InputLine $line
        New-GpuCooldownDeviceObject -Provider 'Nvidia' -Vendor 'NVIDIA' -Name $parsedDevice.Name -ProviderDeviceId $parsedDevice.PciBusId
    }

    return @($devices)
}
