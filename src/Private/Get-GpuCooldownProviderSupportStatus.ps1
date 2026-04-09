function Get-GpuCooldownProviderSupportStatus {
    [CmdletBinding()]
    param()

    $nvidiaSmi = Get-Command -Name 'nvidia-smi' -ErrorAction SilentlyContinue
    if (-not $nvidiaSmi) {
        return [pscustomobject]@{
            IsProviderAvailable = $false
            ProviderName        = 'Nvidia'
            ProviderCommand     = 'nvidia-smi'
            Message             = 'nvidia-smi was not found. NVIDIA GPU discovery and temperature retrieval are unavailable.'
        }
    }

    [pscustomobject]@{
        IsProviderAvailable = $true
        ProviderName        = 'Nvidia'
        ProviderCommand     = 'nvidia-smi'
        Message             = 'nvidia-smi is available.'
    }
}
