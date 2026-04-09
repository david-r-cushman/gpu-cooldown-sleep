BeforeAll {
    $moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\GpuCooldownSleep.psd1'
    Import-Module -Name $moduleManifestPath -Force
}

Describe 'Get-GpuCooldownDevice' {
    Context 'when NVIDIA discovery returns a single device' {
        BeforeAll {
            Mock -CommandName Get-NvidiaGpuCooldownDevice -ModuleName GpuCooldownSleep -MockWith {
                @(
                    [pscustomobject]@{
                        Provider            = 'Nvidia'
                        Vendor              = 'NVIDIA'
                        Name                = 'NVIDIA GeForce RTX 4080'
                        DeviceId            = 'nvidia:00000000:01:00.0'
                        ProviderDeviceId    = '00000000:01:00.0'
                        PciBusId            = '00000000:01:00.0'
                        IsSupported         = $true
                        IsSelectedByDefault = $false
                    }
                )
            }
        }

        It 'marks the device as selected by default' {
            $result = Get-GpuCooldownDevice

            $result | Should -HaveCount 1
            $result[0].IsSelectedByDefault | Should -BeTrue
            $result[0].Provider | Should -Be 'Nvidia'
            $result[0].DeviceId | Should -Be 'nvidia:00000000:01:00.0'
        }
    }

    Context 'when NVIDIA discovery returns multiple devices' {
        BeforeAll {
            Mock -CommandName Get-NvidiaGpuCooldownDevice -ModuleName GpuCooldownSleep -MockWith {
                @(
                    [pscustomobject]@{
                        Provider            = 'Nvidia'
                        Vendor              = 'NVIDIA'
                        Name                = 'GPU 1'
                        DeviceId            = 'nvidia:00000000:01:00.0'
                        ProviderDeviceId    = '00000000:01:00.0'
                        PciBusId            = '00000000:01:00.0'
                        IsSupported         = $true
                        IsSelectedByDefault = $false
                    }
                    [pscustomobject]@{
                        Provider            = 'Nvidia'
                        Vendor              = 'NVIDIA'
                        Name                = 'GPU 2'
                        DeviceId            = 'nvidia:00000000:02:00.0'
                        ProviderDeviceId    = '00000000:02:00.0'
                        PciBusId            = '00000000:02:00.0'
                        IsSupported         = $true
                        IsSelectedByDefault = $false
                    }
                )
            }
        }

        It 'does not mark any device as selected by default' {
            $result = Get-GpuCooldownDevice

            $result | Should -HaveCount 2
            ($result | Where-Object { $_.IsSelectedByDefault }).Count | Should -Be 0
        }
    }

    Context 'when filtering by provider' {
        BeforeAll {
            Mock -CommandName Get-NvidiaGpuCooldownDevice -ModuleName GpuCooldownSleep -MockWith { @() }
        }

        It 'supports provider filtering' {
            { Get-GpuCooldownDevice -Provider Nvidia } | Should -Not -Throw
            Should -Invoke Get-NvidiaGpuCooldownDevice -ModuleName GpuCooldownSleep -Times 1 -Exactly
        }
    }
}
