<#
.SYNOPSIS
    Updates generated Markdown blocks from the central runtime policy.

.DESCRIPTION
    Rewrites known generated blocks in documentation files. The script only
    changes content between matching BEGIN/END generated markers.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [switch]$Check,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$PolicyPath = (Join-Path -Path $PSScriptRoot -ChildPath '..\eng\runtime-policy.json')
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
$resolvedPolicyPath = (Resolve-Path -LiteralPath $PolicyPath).Path
$policy = Get-Content -Raw -LiteralPath $resolvedPolicyPath | ConvertFrom-Json
$checkOnly = $Check.IsPresent
$pendingChanges = [System.Collections.Generic.List[object]]::new()

function Test-GeneratedMarkdownBlock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BlockName
    )

    $path = Join-Path -Path $repoRoot -ChildPath $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        return $false
    }

    $beginMarker = '<!-- BEGIN generated:{0} -->' -f $BlockName
    $content = Get-Content -Raw -LiteralPath $path
    return $content.Contains($beginMarker)
}

function Set-GeneratedMarkdownBlock {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BlockName,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [string[]]$Lines
    )

    if (-not (Test-GeneratedMarkdownBlock -RelativePath $RelativePath -BlockName $BlockName)) {
        return
    }

    $path = Join-Path -Path $repoRoot -ChildPath $RelativePath
    $beginMarker = '<!-- BEGIN generated:{0} -->' -f $BlockName
    $endMarker = '<!-- END generated:{0} -->' -f $BlockName
    $content = Get-Content -Raw -LiteralPath $path
    $escapedBeginMarker = [regex]::Escape($beginMarker)
    $escapedEndMarker = [regex]::Escape($endMarker)
    $pattern = '(?s){0}.*?{1}' -f $escapedBeginMarker, $escapedEndMarker
    $regex = [regex]::new($pattern)

    $replacement = @($beginMarker) + $Lines + @($endMarker)
    $updatedContent = $regex.Replace($content, ($replacement -join "`n"), 1).TrimEnd("`r", "`n") + "`n"

    if ($updatedContent -ne $content) {
        if ($checkOnly) {
            $pendingChanges.Add([pscustomobject]@{
                    Path = $RelativePath
                    BlockName = $BlockName
                    Reason = 'Generated block is out of date'
                })
            return
        }

        if ($PSCmdlet.ShouldProcess($RelativePath, ('Update generated block {0}' -f $BlockName))) {
            [System.IO.File]::WriteAllText($path, $updatedContent, [System.Text.UTF8Encoding]::new($false))
        }
    }
}

$toolingLine = '- **Tooling:** Azure CLI, Pester {0}, PSScriptAnalyzer {1}, and PSReadLine {2}' -f $policy.tooling.pesterVersion, $policy.tooling.psScriptAnalyzerVersion, $policy.tooling.psReadLineVersion
if ($policy.runtime.PSObject.Properties.Name -contains 'developmentHost') {
    $runtimeLine = '- **Runtime:** {0}' -f $policy.runtime.developmentHost
    $runtimeFocusLine = '- PowerShell {0} development on Windows' -f $policy.runtime.powershellVersion
    $baseRuntimeLine = '- **Deterministic Development Runtime:** PowerShell {0} is the maintained baseline, and real module execution stays on a Windows host because the workload is Windows-specific' -f $policy.runtime.powershellVersion
    $controlledRuntimeLine = '- **Controlled Base Runtime:** The repository keeps a PowerShell {0} baseline while real module execution stays on Windows' -f $policy.runtime.powershellVersion
}
else {
    $runtimeLine = '- **Runtime:** PowerShell {0} (LTS) on Ubuntu {1}' -f $policy.runtime.powershellVersionLabel, $policy.runtime.ubuntuVersion
    $runtimeFocusLine = '- PowerShell {0} development' -f $policy.runtime.powershellVersion
    $baseRuntimeLine = '- **Deterministic Base Runtime:** The development container is built from a pinned PowerShell {0} on Ubuntu {1} base image to reduce environmental drift' -f $policy.runtime.powershellVersion, $policy.runtime.ubuntuVersion
    $controlledRuntimeLine = '- **Controlled Base Runtime:** The container starts from a pinned PowerShell {0} on Ubuntu {1} base image' -f $policy.runtime.powershellVersion, $policy.runtime.ubuntuVersion
}

Set-GeneratedMarkdownBlock -RelativePath 'README.md' -BlockName 'readme-powershell-badge' -Lines @(
    '![PowerShell {0}](https://img.shields.io/badge/PowerShell-{0}-blue)' -f $policy.runtime.powershellVersion
)
Set-GeneratedMarkdownBlock -RelativePath 'README.md' -BlockName 'readme-runtime-focus' -Lines @($runtimeFocusLine)
Set-GeneratedMarkdownBlock -RelativePath 'README.md' -BlockName 'readme-runtime-stack' -Lines @($runtimeLine)
Set-GeneratedMarkdownBlock -RelativePath 'README.md' -BlockName 'readme-tooling-list' -Lines @(
    ('- **Pester {0}:** For unit and integration testing' -f $policy.tooling.pesterVersion),
    ('- **PSScriptAnalyzer {0}:** To enforce PowerShell best practices and security rules' -f $policy.tooling.psScriptAnalyzerVersion),
    '- **Azure CLI:** Pre-installed for cloud resource management',
    ('- **PSReadLine {0}:** Configured for a more efficient terminal experience' -f $policy.tooling.psReadLineVersion)
)
Set-GeneratedMarkdownBlock -RelativePath 'README.md' -BlockName 'readme-runtime-philosophy' -Lines @($baseRuntimeLine)

Set-GeneratedMarkdownBlock -RelativePath 'templates/downstream/README.md' -BlockName 'readme-powershell-badge' -Lines @(
    '![PowerShell {0}](https://img.shields.io/badge/PowerShell-{0}-blue)' -f $policy.runtime.powershellVersion
)
Set-GeneratedMarkdownBlock -RelativePath 'templates/downstream/README.md' -BlockName 'readme-runtime-focus' -Lines @($runtimeFocusLine)
Set-GeneratedMarkdownBlock -RelativePath 'templates/downstream/README.md' -BlockName 'readme-runtime-stack' -Lines @($runtimeLine)
Set-GeneratedMarkdownBlock -RelativePath 'templates/downstream/README.md' -BlockName 'readme-tooling-list' -Lines @(
    ('- **Pester {0}:** For unit and integration testing' -f $policy.tooling.pesterVersion),
    ('- **PSScriptAnalyzer {0}:** To enforce PowerShell best practices and security rules' -f $policy.tooling.psScriptAnalyzerVersion),
    '- **Azure CLI:** Pre-installed for cloud resource management',
    ('- **PSReadLine {0}:** Configured for a more efficient terminal experience' -f $policy.tooling.psReadLineVersion)
)
Set-GeneratedMarkdownBlock -RelativePath 'templates/downstream/README.md' -BlockName 'readme-runtime-philosophy' -Lines @($baseRuntimeLine)

Set-GeneratedMarkdownBlock -RelativePath '.github/Instructions/environment-setup.md' -BlockName 'environment-runtime-stack' -Lines @($runtimeLine)
Set-GeneratedMarkdownBlock -RelativePath '.github/Instructions/environment-setup.md' -BlockName 'environment-tooling-stack' -Lines @($toolingLine)
Set-GeneratedMarkdownBlock -RelativePath '.github/Instructions/environment-setup.md' -BlockName 'environment-runtime-principle' -Lines @($controlledRuntimeLine)

if ($pendingChanges.Count -gt 0) {
    $pendingChanges | Format-Table -AutoSize | Out-String | Write-Output
    throw ('Generated Markdown is out of date in {0} block(s).' -f $pendingChanges.Count)
}

Write-Verbose ('Generated Markdown validated from policy: {0}' -f $resolvedPolicyPath)
