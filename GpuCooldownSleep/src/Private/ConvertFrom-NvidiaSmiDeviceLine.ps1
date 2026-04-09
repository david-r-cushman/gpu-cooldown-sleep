function ConvertFrom-NvidiaSmiDeviceLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputLine
    )

    $segments = $InputLine -split ',', 2
    if ($segments.Count -ne 2) {
        throw "Unexpected nvidia-smi device output format: '$InputLine'."
    }

    $name = $segments[0].Trim()
    $pciBusId = $segments[1].Trim()

    if ([string]::IsNullOrWhiteSpace($name)) {
        throw "NVIDIA device output did not include a device name: '$InputLine'."
    }

    if ([string]::IsNullOrWhiteSpace($pciBusId)) {
        throw "NVIDIA device output did not include a PCI bus ID: '$InputLine'."
    }

    [pscustomobject]@{
        Name     = $name
        PciBusId = $pciBusId
    }
}
