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
    # $env:LOCALAPPDATA is null off Windows, and Join-Path throws on a null
    # path. CI never reaches here because it sets $env:GODOT, but a resolver
    # that explodes instead of reporting "not found" is a bad resolver.
    $winget = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages" } else { $null }
    if ($winget -and (Test-Path $winget)) {
        $exe = Get-ChildItem $winget -Filter "Godot_v*_console.exe" -Recurse -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending | Select-Object -First 1
        if ($exe) { return $exe.FullName }
    }
    throw "Godot not found. Put it on PATH or set `$env:GODOT to the executable."
}

$godot = Resolve-Godot
$project = Join-Path $repo "dotbg"
Write-Host "godot: $godot"

# Every *_test.gd under dotbg/tests/ runs. Adding a test file is enough to put
# it in CI — there is no list to remember to update, which is the kind of list
# that silently stops being updated.
$tests = Get-ChildItem (Join-Path $project "tests") -Filter "*_test.gd" | Sort-Object Name
if (-not $tests) { throw "No *_test.gd files found under $project\tests" }

# Import first, always. Godot registers `class_name` declarations into its
# global class cache during import, so a script referencing a newly added class
# fails to parse until this has run. CI does this as its own step; without it
# here, local and CI disagree about whether the code compiles, and local is the
# one that lies.
Write-Host "--- import ---"
& $godot --headless --path $project --import
if ($LASTEXITCODE -ne 0) {
    Write-Host "RESULT: FAIL (import failed)"
    exit 1
}

$failed = @()
foreach ($t in $tests) {
    Write-Host "`n--- $($t.Name) ---"
    & $godot --headless --path $project --script "res://tests/$($t.Name)"
    if ($LASTEXITCODE -ne 0) { $failed += $t.Name }
}

Write-Host "`n=== suite: $($tests.Count) files, $($failed.Count) failing ==="
if ($failed) {
    Write-Host ("FAILED: " + ($failed -join ", "))
    exit 1
}
Write-Host "RESULT: PASS"
exit 0
