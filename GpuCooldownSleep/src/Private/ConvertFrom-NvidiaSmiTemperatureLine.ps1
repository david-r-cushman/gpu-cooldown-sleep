function ConvertFrom-NvidiaSmiTemperatureLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputLine
    )

    $segments = $InputLine -split ',', 2
    if ($segments.Count -ne 2) {
        throw "Unexpected nvidia-smi temperature output format: '$InputLine'."
    }

    $pciBusId = $segments[0].Trim()
    $temperatureText = $segments[1].Trim()

    if ([string]::IsNullOrWhiteSpace($pciBusId)) {
        throw "NVIDIA temperature output did not include a PCI bus ID: '$InputLine'."
    }

    $temperatureValue = 0
    if (-not [int]::TryParse($temperatureText, [ref]$temperatureValue)) {
        throw "NVIDIA temperature output did not include a valid integer temperature: '$InputLine'."
    }

    [pscustomobject]@{
        PciBusId            = $pciBusId
        TemperatureCelsius  = $temperatureValue
    }
}
