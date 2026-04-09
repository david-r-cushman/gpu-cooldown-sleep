function Clear-GpuCooldownProgress {
    [CmdletBinding()]
    param()

    Write-Progress -Id 1 -Activity 'Cooling GPU' -Completed
}
