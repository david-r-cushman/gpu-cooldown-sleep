BeforeAll {
    $moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\GpuCooldownSleep.psd1'
    Import-Module -Name $moduleManifestPath -Force
}

Describe 'Wait-GpuCooldown' {
    Context 'when the target temperature is reached before timeout' {
        BeforeAll {
            $script:temperatureSequence = [System.Collections.Generic.Queue[int]]::new()
            $script:temperatureSequence.Enqueue(48)
            $script:temperatureSequence.Enqueue(44)
            $script:temperatureSequence.Enqueue(40)

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

            Mock -CommandName Get-GpuCooldownTemperature -ModuleName GpuCooldownSleep -MockWith {
                $nextTemperature = $script:temperatureSequence.Dequeue()
                [pscustomobject]@{
                    Provider            = 'Nvidia'
                    Vendor              = 'NVIDIA'
                    Name                = 'NVIDIA GeForce RTX 4080'
                    DeviceId            = 'nvidia:00000000:01:00.0'
                    ProviderDeviceId    = '00000000:01:00.0'
                    PciBusId            = '00000000:01:00.0'
                    TemperatureCelsius  = $nextTemperature
                    RetrievedAt         = Get-Date
                }
            }

            Mock -CommandName Start-Sleep -ModuleName GpuCooldownSleep
        }

        It 'returns a target reached result' {
            $result = Wait-GpuCooldown -TargetTemperature 40 -PollIntervalSeconds 1 -TimeoutMinutes 5

            $result.Status | Should -Be 'TargetReached'
            $result.FinalTemperatureCelsius | Should -Be 40
            Should -Invoke Start-Sleep -ModuleName GpuCooldownSleep -Times 2 -Exactly
        }
    }

    Context 'when the timeout is reached before the target temperature' {
        BeforeAll {
            Mock -CommandName Resolve-GpuCooldownDevice -ModuleName GpuCooldownSleep -MockWith {
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
            }

            Mock -CommandName Get-GpuCooldownTemperature -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    Provider            = 'Nvidia'
                    Vendor              = 'NVIDIA'
                    Name                = 'NVIDIA GeForce RTX 4080'
                    DeviceId            = 'nvidia:00000000:01:00.0'
                    ProviderDeviceId    = '00000000:01:00.0'
                    PciBusId            = '00000000:01:00.0'
                    TemperatureCelsius  = 55
                    RetrievedAt         = Get-Date
                }
            }

            Mock -CommandName Start-Sleep -ModuleName GpuCooldownSleep
        }

        It 'returns a timed out result when no cooldown occurs' {
            $result = Wait-GpuCooldown -TargetTemperature 40 -PollIntervalSeconds 60 -TimeoutMinutes 1

            $result.Status | Should -Be 'TimedOut'
            $result.FinalTemperatureCelsius | Should -Be 55
        }
    }
}
