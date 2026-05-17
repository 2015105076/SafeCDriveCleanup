param(
    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = 'Continue'
$script:BeforeBytes = 0
$script:AfterBytes = 0
$script:LogLines = New-Object System.Collections.Generic.List[string]

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    $script:LogLines.Add($line) | Out-Null
    if (-not $Quiet) { Write-Host $line }
}

function Get-DirectoryBytes {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $sum = (Get-ChildItem -LiteralPath $Path -Force -Recurse -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    if ($null -eq $sum) { return 0 }
    return [int64]$sum
}

function Convert-BytesToGB {
    param([int64]$Bytes)
    return [math]::Round($Bytes / 1GB, 2)
}

function Get-FullPath {
    param([string]$Path)
    return [System.IO.Path]::GetFullPath($Path)
}

function Test-SafeCleanupPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }

    $full = Get-FullPath $Path
    $allowed = @(
        (Get-FullPath $env:TEMP),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Temp')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'CrashDumps')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\INetCache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'pip\Cache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'npm-cache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'NVIDIA\DXCache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'NVIDIA\GLCache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Default\Cache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Default\Code Cache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data\Default\Cache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data\Default\Code Cache')),
        (Get-FullPath (Join-Path $env:LOCALAPPDATA 'Adobe\CameraRaw\Cache2')),
        (Get-FullPath (Join-Path $env:ProgramData 'Microsoft\Windows\WER')),
        (Get-FullPath (Join-Path $env:windir 'Temp')),
        (Get-FullPath (Join-Path $env:windir 'SoftwareDistribution\Download'))
    )

    foreach ($item in $allowed) {
        if ($full.Equals($item, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Clear-DirectoryContents {
    param(
        [string]$Path,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Log "Skip missing target: $Label ($Path)"
        return
    }
    if (-not (Test-SafeCleanupPath -Path $Path)) {
        Write-Log "Refused non-whitelisted path: $Path"
        return
    }

    $before = Get-DirectoryBytes -Path $Path
    $script:BeforeBytes += $before
    Write-Log ("Cleaning {0}: before {1} GB" -f $Label, (Convert-BytesToGB $before))

    if (-not $DryRun) {
        Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    $after = Get-DirectoryBytes -Path $Path
    $script:AfterBytes += $after
    Write-Log ("Finished {0}: after {1} GB" -f $Label, (Convert-BytesToGB $after))
}

function Clear-MatchingFiles {
    param(
        [string]$Path,
        [string[]]$Patterns,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Log "Skip missing target: $Label ($Path)"
        return
    }
    if (-not (Test-SafeCleanupPath -Path $Path)) {
        Write-Log "Refused non-whitelisted path: $Path"
        return
    }

    $before = Get-DirectoryBytes -Path $Path
    $script:BeforeBytes += $before
    Write-Log ("Cleaning {0}: directory before {1} GB" -f $Label, (Convert-BytesToGB $before))

    if (-not $DryRun) {
        foreach ($pattern in $Patterns) {
            Get-ChildItem -LiteralPath $Path -Force -File -Filter $pattern -ErrorAction SilentlyContinue |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }

    $after = Get-DirectoryBytes -Path $Path
    $script:AfterBytes += $after
    Write-Log ("Finished {0}: directory after {1} GB" -f $Label, (Convert-BytesToGB $after))
}

function Get-CDriveFreeGB {
    $drive = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.Name -eq 'C:\' } | Select-Object -First 1
    if ($null -eq $drive) { return $null }
    return [math]::Round($drive.AvailableFreeSpace / 1GB, 2)
}

Write-Log "Safe C drive cache cleanup started. Mode: $(if ($DryRun) { 'dry run' } else { 'delete' })"
$freeBefore = Get-CDriveFreeGB
if ($null -ne $freeBefore) { Write-Log "C drive free before: $freeBefore GB" }

$targets = @(
    @{ Path = $env:TEMP; Label = 'User TEMP' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'Temp'); Label = 'LocalAppData Temp' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'CrashDumps'); Label = 'Crash dumps' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\INetCache'); Label = 'INetCache' },
    @{ Path = (Join-Path $env:ProgramData 'Microsoft\Windows\WER'); Label = 'Windows Error Reporting cache' },
    @{ Path = (Join-Path $env:windir 'Temp'); Label = 'Windows Temp' },
    @{ Path = (Join-Path $env:windir 'SoftwareDistribution\Download'); Label = 'Windows Update download cache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'pip\Cache'); Label = 'pip cache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'npm-cache'); Label = 'npm cache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'NVIDIA\DXCache'); Label = 'NVIDIA DXCache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'NVIDIA\GLCache'); Label = 'NVIDIA GLCache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Default\Cache'); Label = 'Chrome cache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Default\Code Cache'); Label = 'Chrome code cache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data\Default\Cache'); Label = 'Edge cache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data\Default\Code Cache'); Label = 'Edge code cache' },
    @{ Path = (Join-Path $env:LOCALAPPDATA 'Adobe\CameraRaw\Cache2'); Label = 'Adobe CameraRaw Cache2' }
)

foreach ($target in $targets) {
    Clear-DirectoryContents -Path $target.Path -Label $target.Label
}

Clear-MatchingFiles `
    -Path (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer') `
    -Patterns @('thumbcache_*.db', 'iconcache_*.db') `
    -Label 'Explorer thumbnail and icon cache'

$freed = $script:BeforeBytes - $script:AfterBytes
$freeAfter = Get-CDriveFreeGB
Write-Log ("Estimated freed space: {0} GB" -f (Convert-BytesToGB $freed))
if ($null -ne $freeAfter) { Write-Log "C drive free after: $freeAfter GB" }

$logDir = Join-Path $env:LOCALAPPDATA 'SafeCDriveCleanup\Logs'
try {
    New-Item -ItemType Directory -Path $logDir -Force -ErrorAction Stop | Out-Null
    $logFile = Join-Path $logDir ("cleanup-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $script:LogLines | Set-Content -LiteralPath $logFile -Encoding UTF8 -ErrorAction Stop
    Write-Host ""
    Write-Host "Log saved to: $logFile"
}
catch {
    Write-Host ""
    Write-Host "Log could not be saved: $($_.Exception.Message)"
}

if (-not $Quiet) {
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
