BeforeAll {
    $repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $moduleRoot = Join-Path -Path $repoRoot -ChildPath 'GpuCooldownSleep'
    $moduleManifestPath = Join-Path -Path $moduleRoot -ChildPath 'GpuCooldownSleep.psd1'
    Import-Module -Name $moduleManifestPath -Force
}

Describe 'Test-GpuCooldownSupport' {
    Context 'when the environment is fully supported' {
        BeforeAll {
            Mock -CommandName Get-GpuCooldownProviderSupportStatus -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    IsProviderAvailable = $true
                    ProviderName        = 'Nvidia'
                    ProviderCommand     = 'nvidia-smi'
                    Message             = 'nvidia-smi is available.'
                }
            }

            Mock -CommandName Get-SupportedGpuCooldownDevicesSafely -ModuleName GpuCooldownSleep -MockWith {
                @(
                    [pscustomobject]@{
                        Name = 'NVIDIA GeForce RTX 4080'
                    }
                )
            }

            Mock -CommandName Test-GpuCooldownSleepSupport -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    IsSupported = $true
                    IsWindows   = $true
                    Message     = 'System sleep APIs are available.'
                }
            }

            Mock -CommandName Test-GpuCooldownKeepAwakeSupport -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    IsSupported = $true
                    Message     = 'SetThreadExecutionState interop is available.'
                }
            }
        }

        It 'returns a supported summary' {
            $result = Test-GpuCooldownSupport

            $result.IsSupported | Should -BeTrue
            $result.MonitoringSupported | Should -BeTrue
            $result.SupportedDeviceCount | Should -Be 1
            $result.ProviderAvailable | Should -BeTrue
            $result.SleepSupported | Should -BeTrue
            $result.KeepAwakeSupported | Should -BeTrue
        }
    }

    Context 'when the provider dependency is missing' {
        BeforeAll {
            Mock -CommandName Get-GpuCooldownProviderSupportStatus -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    IsProviderAvailable = $false
                    ProviderName        = 'Nvidia'
                    ProviderCommand     = 'nvidia-smi'
                    Message             = 'nvidia-smi was not found.'
                }
            }

            Mock -CommandName Get-SupportedGpuCooldownDevicesSafely -ModuleName GpuCooldownSleep -MockWith { @() }

            Mock -CommandName Test-GpuCooldownSleepSupport -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    IsSupported = $true
                    IsWindows   = $true
                    Message     = 'System sleep APIs are available.'
                }
            }

            Mock -CommandName Test-GpuCooldownKeepAwakeSupport -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    IsSupported = $true
                    Message     = 'SetThreadExecutionState interop is available.'
                }
            }
        }

        It 'reports the environment as unsupported' {
            $result = Test-GpuCooldownSupport

            $result.IsSupported | Should -BeFalse
            $result.MonitoringSupported | Should -BeFalse
            $result.ProviderAvailable | Should -BeFalse
            $result.ProviderStatusMessage | Should -Be 'nvidia-smi was not found.'
        }
    }
}
