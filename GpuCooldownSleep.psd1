@{
    RootModule        = 'GpuCooldownSleep.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '2f48fc31-4014-453b-b0c5-6d19d31ad942'
    Author            = 'David R. Cushman'
    CompanyName       = 'Personal'
    Copyright         = '(c) 2026 David R. Cushman. All rights reserved.'
    Description       = 'PowerShell module for monitoring GPU temperature and coordinating cooldown-driven sleep workflows.'
    PowerShellVersion = '7.4'
    FunctionsToExport = @(
        'Get-GpuCooldownDevice'
        'Get-GpuCooldownTemperature'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('PowerShell', 'GPU', 'Thermal', 'Sleep', 'NVIDIA')
            ProjectUri = 'https://github.com/david-r-cushman/gpu-cooldown-sleep'
            LicenseUri = 'https://github.com/david-r-cushman/gpu-cooldown-sleep/blob/main/LICENSE'
        }
    }
}
