#Requires -Version 5.1
[CmdletBinding()]
param(
    [string[]]$Id,
    [string[]]$Category,
    [string]$Destination = $PSScriptRoot,
    [switch]$List
)

$ErrorActionPreference = 'Stop'
$catalogue = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'catalogue.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$packages = @($catalogue.packages | Where-Object { $_.downloadUrl })
if ($Id) {
    $unknown = @($Id | Where-Object { $_ -notin $packages.id })
    if ($unknown) { throw ('Unknown or local-only package ID: ' + ($unknown -join ', ')) }
    $packages = @($packages | Where-Object { $_.id -in $Id })
}
if ($Category) {
    $unknown = @($Category | Where-Object { $_ -notin $packages.category })
    if ($unknown) { throw ('Unknown category: ' + ($unknown -join ', ')) }
    $packages = @($packages | Where-Object { $_.category -in $Category })
}
if ($List) {
    $packages | Select-Object id, name, version, category, downloadKind, bytes
    return
}
if (-not $packages.Count) { throw 'No packages matched the selection.' }
$curl = Get-Command curl.exe -ErrorAction Stop
$destinationRoot = [IO.Path]::GetFullPath($Destination).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$destinationPrefix = $destinationRoot + [IO.Path]::DirectorySeparatorChar
New-Item -ItemType Directory -Path $destinationRoot -Force | Out-Null
$failures = @()
$completed = 0
foreach ($package in $packages) {
    try {
        $downloadUri = [Uri]$package.downloadUrl
        if (-not $downloadUri.IsAbsoluteUri -or $downloadUri.Scheme -ne 'https' -or $downloadUri.UserInfo) { throw 'Only HTTPS URLs without embedded credentials are supported.' }
        if ($package.sha256 -notmatch '^[a-fA-F0-9]{64}$') { throw 'Missing or invalid SHA256.' }
        if ([IO.Path]::IsPathRooted($package.file)) { throw 'Absolute archive paths are not allowed.' }
        $targetPath = [IO.Path]::GetFullPath((Join-Path $destinationRoot $package.file))
        if (-not $targetPath.StartsWith($destinationPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Archive path escapes the destination folder.' }
        if (Test-Path -LiteralPath $targetPath) {
            $existingHash = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash
            if ($existingHash -ne $package.sha256) { throw 'Existing file differs from catalogue; preserved. Choose another destination or remove the file yourself.' }
            Write-Host ('Verified existing: ' + $package.name)
            $completed++
            continue
        }
        New-Item -ItemType Directory -Path (Split-Path -Parent $targetPath) -Force | Out-Null
        $partialPath = $targetPath + '.part'
        $arguments = @('--fail', '--location', '--retry', '2', '--retry-all-errors', '--retry-delay', '3', '--connect-timeout', '25', '--max-time', '1800', '--silent', '--show-error', '--output', $partialPath)
        if ($package.referer) { $arguments += @('--referer', [string]$package.referer) }
        if ($package.postData) { $arguments += @('--data', [string]$package.postData) }
        $arguments += [string]$package.downloadUrl
        Write-Host ('Downloading: ' + $package.name + ' ' + $package.version)
        & $curl.Source @arguments
        if ($LASTEXITCODE -ne 0) { throw ('Download failed, curl exit ' + $LASTEXITCODE) }
        $actualHash = (Get-FileHash -LiteralPath $partialPath -Algorithm SHA256).Hash
        if ($actualHash -ne $package.sha256) { throw 'SHA256 differs. A dynamic publisher URL may now serve a newer version; the partial file is retained and never executed.' }
        if ((Get-Item -LiteralPath $partialPath).Length -ne [long]$package.bytes) { throw 'Installer size differs from catalogue.' }
        Move-Item -LiteralPath $partialPath -Destination $targetPath
        Write-Host ('Saved and verified: ' + $package.name)
        $completed++
    } catch {
        $failures += [pscustomobject]@{ id = $package.id; error = $_.Exception.Message }
        Write-Warning ($package.name + ': ' + $_.Exception.Message)
    }
}
Write-Host ('Finished: {0}/{1} installers verified. Nothing was installed.' -f $completed, $packages.Count)
if ($failures.Count) {
    $failures | Format-Table -Wrap | Out-Host
    throw ('Failed to download/verify ' + $failures.Count + ' installer(s).')
}
