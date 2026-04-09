BeforeAll {
    $moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\GpuCooldownSleep.psd1'
    Import-Module -Name $moduleManifestPath -Force
}

Describe 'Get-GpuCooldownTemperature' {
    Context 'when a single supported device is discoverable' {
        BeforeAll {
            Mock -CommandName Get-GpuCooldownDevice -ModuleName GpuCooldownSleep -MockWith {
                @(
                    [pscustomobject]@{
                        Provider            = 'Nvidia'
                        Vendor              = 'NVIDIA'
                        Name                = 'NVIDIA GeForce RTX 4080'
                        DeviceId            = 'nvidia:00000000:01:00.0'
                        ProviderDeviceId    = '00000000:01:00.0'
                        PciBusId            = '00000000:01:00.0'
                        IsSupported         = $true
                        IsSelectedByDefault = $true
                    }
                )
            }

            Mock -CommandName Get-NvidiaGpuCooldownTemperature -ModuleName GpuCooldownSleep -MockWith {
                param($Device)

                [pscustomobject]@{
                    Provider            = $Device.Provider
                    Vendor              = $Device.Vendor
                    Name                = $Device.Name
                    DeviceId            = $Device.DeviceId
                    ProviderDeviceId    = $Device.ProviderDeviceId
                    PciBusId            = $Device.PciBusId
                    TemperatureCelsius  = 46
                    RetrievedAt         = [datetime]'2026-04-09T12:00:00'
                }
            }
        }

        It 'returns the current temperature when called without a device selector' {
            $result = Get-GpuCooldownTemperature

            $result.DeviceId | Should -Be 'nvidia:00000000:01:00.0'
            $result.TemperatureCelsius | Should -Be 46
        }
    }

    Context 'when multiple supported devices are discoverable' {
        BeforeAll {
            Mock -CommandName Get-GpuCooldownDevice -ModuleName GpuCooldownSleep -MockWith {
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

        It 'requires explicit selection when multiple devices are found' {
            { Get-GpuCooldownTemperature } | Should -Throw 'Multiple supported GPU devices were discovered*'
        }
    }

    Context 'when a device object is provided on the pipeline' {
        BeforeAll {
            Mock -CommandName Get-NvidiaGpuCooldownTemperature -ModuleName GpuCooldownSleep -MockWith {
                param($Device)

                [pscustomobject]@{
                    Provider            = $Device.Provider
                    Vendor              = $Device.Vendor
                    Name                = $Device.Name
                    DeviceId            = $Device.DeviceId
                    ProviderDeviceId    = $Device.ProviderDeviceId
                    PciBusId            = $Device.PciBusId
                    TemperatureCelsius  = 41
                    RetrievedAt         = [datetime]'2026-04-09T12:00:00'
                }
            }
        }

        It 'uses the supplied device object directly' {
            $device = [pscustomobject]@{
                Provider            = 'Nvidia'
                Vendor              = 'NVIDIA'
                Name                = 'NVIDIA GeForce RTX 4080'
                DeviceId            = 'nvidia:00000000:01:00.0'
                ProviderDeviceId    = '00000000:01:00.0'
                PciBusId            = '00000000:01:00.0'
                IsSupported         = $true
                IsSelectedByDefault = $true
            }

            $result = $device | Get-GpuCooldownTemperature

            $result.TemperatureCelsius | Should -Be 41
            Should -Invoke Get-NvidiaGpuCooldownTemperature -ModuleName GpuCooldownSleep -Times 1 -Exactly
        }
    }

    Context 'when selecting a device by friendly name' {
        BeforeAll {
            Mock -CommandName Get-GpuCooldownDevice -ModuleName GpuCooldownSleep -MockWith {
                @(
                    [pscustomobject]@{
                        Provider            = 'Nvidia'
                        Vendor              = 'NVIDIA'
                        Name                = 'NVIDIA GeForce RTX 4080'
                        DeviceId            = 'nvidia:00000000:01:00.0'
                        ProviderDeviceId    = '00000000:01:00.0'
                        PciBusId            = '00000000:01:00.0'
                        IsSupported         = $true
                        IsSelectedByDefault = $true
                    }
                )
            }

            Mock -CommandName Get-NvidiaGpuCooldownTemperature -ModuleName GpuCooldownSleep -MockWith {
                param($Device)

                [pscustomobject]@{
                    Provider            = $Device.Provider
                    Vendor              = $Device.Vendor
                    Name                = $Device.Name
                    DeviceId            = $Device.DeviceId
                    ProviderDeviceId    = $Device.ProviderDeviceId
                    PciBusId            = $Device.PciBusId
                    TemperatureCelsius  = 39
                    RetrievedAt         = [datetime]'2026-04-09T12:00:00'
                }
            }
        }

        It 'supports name-based selection' {
            $result = Get-GpuCooldownTemperature -Name 'NVIDIA GeForce RTX 4080'

            $result.Name | Should -Be 'NVIDIA GeForce RTX 4080'
            $result.TemperatureCelsius | Should -Be 39
        }
    }
}
