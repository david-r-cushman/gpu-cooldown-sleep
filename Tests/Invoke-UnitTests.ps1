param()

$configuration = New-PesterConfiguration
$configuration.Run.Path = 'Tests/Unit'
$configuration.Run.Exit = $true
$configuration.TestRegistry.Enabled = $false

Invoke-Pester -Configuration $configuration
