$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'src\Public'
$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'src\Private'

$privateFiles = Get-ChildItem -Path $privatePath -Filter '*.ps1' -File -ErrorAction SilentlyContinue | Sort-Object -Property Name
foreach ($file in $privateFiles) {
    . $file.FullName
}

$publicFiles = Get-ChildItem -Path $publicPath -Filter '*.ps1' -File -ErrorAction SilentlyContinue | Sort-Object -Property Name
foreach ($file in $publicFiles) {
    . $file.FullName
}

$exportedFunctions = $publicFiles.BaseName
if ($exportedFunctions.Count -gt 0) {
    Export-ModuleMember -Function $exportedFunctions
}
