#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Root = $PSScriptRoot,
    [string[]]$Id,
    [switch]$AvailableOnly
)
$ErrorActionPreference = 'Stop'
$catalogue = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'catalogue.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$packages = @($catalogue.packages)
if ($Id) {
    $unknown = @($Id | Where-Object { $_ -notin $packages.id })
    if ($unknown) { throw ('Unknown package ID: ' + ($unknown -join ', ')) }
    $packages = @($packages | Where-Object { $_.id -in $Id })
}
if (-not $packages.Count) { throw 'No packages matched the selection.' }
$archiveRoot = [IO.Path]::GetFullPath($Root).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$archivePrefix = $archiveRoot + [IO.Path]::DirectorySeparatorChar
$failures = @()
$verified = 0
$skipped = 0
foreach ($package in $packages) {
    if ([IO.Path]::IsPathRooted($package.file)) { throw 'Absolute archive paths are not allowed.' }
    $path = [IO.Path]::GetFullPath((Join-Path $archiveRoot $package.file))
    if (-not $path.StartsWith($archivePrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Archive path escapes the root.' }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        if ($AvailableOnly) { $skipped++; continue }
        $failures += ($package.id + ': missing')
        continue
    }
    if ($package.sha256 -notmatch '^[a-fA-F0-9]{64}$') { throw ('Invalid catalogue hash: ' + $package.id) }
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    if ($hash -ne $package.sha256 -or (Get-Item -LiteralPath $path).Length -ne [long]$package.bytes) {
        $failures += ($package.id + ': hash or size differs')
        continue
    }
    $verified++
}
Write-Host ('Verified {0} installers; skipped {1}; failed {2}.' -f $verified, $skipped, $failures.Count)
if ($failures.Count) {
    $failures | ForEach-Object { Write-Warning $_ }
    throw 'Installer verification failed.'
}
