# Runs a Blender Python script headless. Exits with Blender's exit code.
#
#   tools\blender.ps1 -Script art\gen\smoke.py [-- extra args for the script]
#
# Blender is not on PATH, so this resolves it: $env:BLENDER -> PATH ->
# "C:\Program Files\Blender Foundation\Blender *" (highest version wins).
#
# It also enforces the batch discipline AGENTS.md requires. This machine has
# ~1 GB of RAM free of 15.6 GB and an integrated GPU; Blender, Godot and an
# agent do not fit at once. Refusing to start is cheaper than thrashing swap
# for twenty minutes and failing anyway. -Force overrides both guards.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Script,
    [switch]$Force,
    [int]$MinFreeMB = 2500,
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$ScriptArgs
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot

function Resolve-Blender {
    if ($env:BLENDER -and (Test-Path $env:BLENDER)) { return $env:BLENDER }
    $onPath = Get-Command blender -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }
    $root = "C:\Program Files\Blender Foundation"
    if (Test-Path $root) {
        $exe = Get-ChildItem $root -Filter "blender.exe" -Recurse -Depth 2 -ErrorAction SilentlyContinue |
               Sort-Object FullName -Descending | Select-Object -First 1
        if ($exe) { return $exe.FullName }
    }
    throw "Blender not found. Put it on PATH or set `$env:BLENDER to blender.exe."
}

if (-not $Force) {
    $godot = Get-Process -Name "Godot*" -ErrorAction SilentlyContinue
    if ($godot) {
        throw "Godot is running (PID $($godot.Id -join ', ')). Close it before a Blender batch, or pass -Force. See AGENTS.md batch discipline."
    }
    $freeMB = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024)
    if ($freeMB -lt $MinFreeMB) {
        throw "Only ${freeMB} MB RAM free, need ${MinFreeMB} MB. Close something, or pass -Force and accept the swap thrash."
    }
}

$scriptPath = if ([System.IO.Path]::IsPathRooted($Script)) { $Script } else { Join-Path $repo $Script }
if (-not (Test-Path $scriptPath)) { throw "Script not found: $scriptPath" }

$blender = Resolve-Blender
Write-Host "blender: $blender"
Write-Host "script:  $scriptPath"

# --factory-startup ignores user prefs and add-ons so a run is reproducible
# anywhere, which is what makes the output safe to commit as a build artifact.
$argv = @("--background", "--factory-startup", "--python-exit-code", "1", "--python", $scriptPath)
if ($ScriptArgs) { $argv += @("--") + $ScriptArgs }

& $blender @argv
exit $LASTEXITCODE
