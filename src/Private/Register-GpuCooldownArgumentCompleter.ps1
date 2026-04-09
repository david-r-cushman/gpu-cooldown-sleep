function Register-GpuCooldownArgumentCompleter {
    [CmdletBinding()]
    param()

    $commandNames = @(
        'Get-GpuCooldownTemperature'
        'Wait-GpuCooldown'
        'Start-GpuCooldownSleep'
    )

    foreach ($commandName in $commandNames) {
        Register-ArgumentCompleter -CommandName $commandName -ParameterName 'Name' -ScriptBlock {
            param($commandName, $parameterName, $wordToComplete)

            $discoveredDevices = @(Get-GpuCooldownDevice)
            foreach ($device in $discoveredDevices) {
                if ($device.Name -like "$wordToComplete*") {
                    [System.Management.Automation.CompletionResult]::new(
                        $device.Name,
                        $device.Name,
                        'ParameterValue',
                        $device.Name
                    )
                }
            }
        }
    }
}
