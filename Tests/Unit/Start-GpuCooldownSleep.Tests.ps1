BeforeAll {
    $moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\GpuCooldownSleep.psd1'
    Import-Module -Name $moduleManifestPath -Force
}

Describe 'Start-GpuCooldownSleep' {
    Context 'when the cooldown target is reached' {
        BeforeAll {
            Mock -CommandName Wait-GpuCooldown -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    Provider                = 'Nvidia'
                    Vendor                  = 'NVIDIA'
                    Name                    = 'NVIDIA GeForce RTX 4080'
                    DeviceId                = 'nvidia:00000000:01:00.0'
                    ProviderDeviceId        = '00000000:01:00.0'
                    PciBusId                = '00000000:01:00.0'
                    TargetTemperature       = 40
                    FinalTemperatureCelsius = 40
                    Status                  = 'TargetReached'
                    StartedAt               = [datetime]'2026-04-09T12:00:00'
                    CompletedAt             = [datetime]'2026-04-09T12:01:00'
                    DurationSeconds         = 60
                }
            }

            Mock -CommandName Start-SystemSleep -ModuleName GpuCooldownSleep
            Mock -CommandName Request-SystemAwake -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    PreviousState = [uint32]0
                }
            }
            Mock -CommandName Restore-SystemAwakeState -ModuleName GpuCooldownSleep
        }

        It 'initiates system sleep when the target is reached' {
            $result = Start-GpuCooldownSleep -TargetTemperature 40 -Confirm:$false

            $result.Status | Should -Be 'TargetReached'
            Should -Invoke Start-SystemSleep -ModuleName GpuCooldownSleep -Times 1 -Exactly
        }

        It 'supports WhatIf without initiating system sleep' {
            $result = Start-GpuCooldownSleep -TargetTemperature 40 -WhatIf

            $result.Status | Should -Be 'TargetReached'
            Should -Invoke Start-SystemSleep -ModuleName GpuCooldownSleep -Times 0 -Exactly
        }

        It 'requests and restores keep-awake behavior when asked' {
            $null = Start-GpuCooldownSleep -TargetTemperature 40 -PreventSystemSleep -Confirm:$false

            Should -Invoke Request-SystemAwake -ModuleName GpuCooldownSleep -Times 1 -Exactly
            Should -Invoke Restore-SystemAwakeState -ModuleName GpuCooldownSleep -Times 1 -Exactly
        }
    }

    Context 'when the cooldown target is not reached before timeout' {
        BeforeAll {
            Mock -CommandName Wait-GpuCooldown -ModuleName GpuCooldownSleep -MockWith {
                [pscustomobject]@{
                    Provider                = 'Nvidia'
                    Vendor                  = 'NVIDIA'
                    Name                    = 'NVIDIA GeForce RTX 4080'
                    DeviceId                = 'nvidia:00000000:01:00.0'
                    ProviderDeviceId        = '00000000:01:00.0'
                    PciBusId                = '00000000:01:00.0'
                    TargetTemperature       = 40
                    FinalTemperatureCelsius = 55
                    Status                  = 'TimedOut'
                    StartedAt               = [datetime]'2026-04-09T12:00:00'
                    CompletedAt             = [datetime]'2026-04-09T12:05:00'
                    DurationSeconds         = 300
                }
            }

            Mock -CommandName Start-SystemSleep -ModuleName GpuCooldownSleep
        }

        It 'returns the timeout result without initiating sleep' {
            $result = Start-GpuCooldownSleep -TargetTemperature 40 -Confirm:$false

            $result.Status | Should -Be 'TimedOut'
            Should -Invoke Start-SystemSleep -ModuleName GpuCooldownSleep -Times 0 -Exactly
        }
    }
}
