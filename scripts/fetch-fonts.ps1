[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$manifestPath = Join-Path $repoRoot 'fonts.manifest.json'
$downloadsDir = Join-Path $repoRoot 'downloads'

if (-not (Test-Path -LiteralPath $downloadsDir)) {
    New-Item -ItemType Directory -Path $downloadsDir -Force | Out-Null
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -Depth 10
foreach ($font in $manifest.fonts) {
    $assetName = [string]$font.releaseAsset
    $targetPath = Join-Path $downloadsDir $assetName
    if (Test-Path -LiteralPath $targetPath) {
        Write-Host ("Using cached asset: {0}" -f $assetName)
        continue
    }

    $uri = if ($font.PSObject.Properties['sourceUrl']) {
        [string]$font.sourceUrl
    } else {
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$assetName"
    }

    Write-Host ("Downloading: {0}" -f $assetName)
    Invoke-WebRequest -Uri $uri -OutFile $targetPath
}

Write-Host ("Font assets ready in: {0}" -f $downloadsDir)
