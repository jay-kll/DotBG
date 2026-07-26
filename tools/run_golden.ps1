# Renders the golden images and compares them against the approved baselines.
# Exits 0 on match (or when there is no baseline yet), non-zero on drift.
#
# Separate from run_tests.ps1 on purpose: this one needs a real rendering
# context. Godot's headless display driver does not rasterise — get_image() on
# the viewport returns null, verified on 4.7.1 — so a window is opened. On a
# machine with no display, drive it through xvfb.
#
# Resolution is pinned. A golden harness that renders at whatever size the
# window happens to be compares nothing.

[CmdletBinding()]
param(
    [switch]$Force,
    [int]$MinFreeMB = 1500
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot

function Resolve-Godot {
    if ($env:GODOT -and (Test-Path $env:GODOT)) { return $env:GODOT }
    $onPath = Get-Command godot -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }
    $winget = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages" } else { $null }
    if ($winget -and (Test-Path $winget)) {
        $exe = Get-ChildItem $winget -Filter "Godot_v*_console.exe" -Recurse -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending | Select-Object -First 1
        if ($exe) { return $exe.FullName }
    }
    throw "Godot not found. Put it on PATH or set `$env:GODOT to the executable."
}

if (-not $Force -and $IsWindows -ne $false) {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($os) {
        $freeMB = [math]::Round($os.FreePhysicalMemory / 1024)
        if ($freeMB -lt $MinFreeMB) {
            throw "Only ${freeMB} MB RAM free, need ${MinFreeMB} MB to open a rendering context. See AGENTS.md batch discipline."
        }
    }
}

$godot = Resolve-Godot
$project = Join-Path $repo "dotbg"
$current = Join-Path $repo "art/golden/current"
$approved = Join-Path $repo "art/golden/approved"

Write-Host "godot:    $godot"
Write-Host "current:  $current"
Write-Host "approved: $approved"

& $godot --headless --path $project --import
if ($LASTEXITCODE -ne 0) { Write-Host "RESULT: FAIL (import failed)"; exit 1 }

& $godot --path $project --resolution 640x360 --script res://tests/golden_render.gd -- $current $approved
exit $LASTEXITCODE
