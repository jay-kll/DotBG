# Runs the headless test suite. Exits 0 on pass, non-zero on failure.
#
# Exists because `godot` is not on PATH on the maintainer's machine (installed
# via winget, which creates no shim), so the bare `godot --headless ...` command
# that the docs used to quote failed with "command not found" — a gate nobody
# could actually run. Resolution order: $env:GODOT, then PATH, then winget.

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot

function Resolve-Godot {
    if ($env:GODOT -and (Test-Path $env:GODOT)) { return $env:GODOT }
    $onPath = Get-Command godot -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }
    $winget = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    if (Test-Path $winget) {
        $exe = Get-ChildItem $winget -Filter "Godot_v*_console.exe" -Recurse -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending | Select-Object -First 1
        if ($exe) { return $exe.FullName }
    }
    throw "Godot not found. Put it on PATH or set `$env:GODOT to the executable."
}

$godot = Resolve-Godot
Write-Host "godot: $godot"
& $godot --headless --path (Join-Path $repo "dotbg") --script res://tests/boot_test.gd
exit $LASTEXITCODE
