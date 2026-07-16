# deploy_game.ps1 - deploy the game build and landing page to Firebase Hosting
# Prereq: Godot Web export done to export/web/ (preset "Web").
# Usage: run from anywhere; paths are script-relative.
# NOTE: keep this file ASCII-only for PowerShell 5.1 compatibility.
$ErrorActionPreference = "Stop"

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$exportDir = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "export\web"))
$landingDir = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "Web\landing"))
$introDir = [System.IO.Path]::GetFullPath((Join-Path $exportDir "intro"))

if (-not (Test-Path -LiteralPath (Join-Path $exportDir "index.html"))) {
    Write-Error "export/web/index.html not found - export from Godot (Web preset) first."
}

# Build the landing assets from the repository data and final art sources.
& (Join-Path $landingDir "build.ps1")

# Recreate only export/web/intro so stale landing files cannot survive a deploy.
$expectedPrefix = $exportDir.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $introDir.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to replace intro outside export/web: $introDir"
}
if (Test-Path -LiteralPath $introDir) {
    Remove-Item -LiteralPath $introDir -Recurse -Force
}

$introAssets = Join-Path $introDir "assets"
New-Item -ItemType Directory -Force -Path $introDir, $introAssets | Out-Null
Copy-Item -LiteralPath (Join-Path $landingDir "index.html") -Destination $introDir -Force
Copy-Item -LiteralPath (Join-Path $landingDir "style.css") -Destination $introDir -Force
Copy-Item -LiteralPath (Join-Path $landingDir "main.js") -Destination $introDir -Force
Get-ChildItem -LiteralPath (Join-Path $landingDir "assets") | Copy-Item -Destination $introAssets -Recurse -Force

# Bridge and config are not part of the Godot export; ship them alongside.
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "public\config.js") -Destination $exportDir -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "web\crush-online.js") -Destination $exportDir -Force

# hosting.public must live under the config file directory.
Set-Location $repoRoot
$firebaseCommand = Get-Command "firebase" -ErrorAction SilentlyContinue
if ($null -ne $firebaseCommand) {
    $firebasePath = $firebaseCommand.Source
} else {
    $userFirebase = Join-Path $env:APPDATA "npm\firebase.cmd"
    if (Test-Path -LiteralPath $userFirebase) {
        $firebasePath = $userFirebase
    } else {
        throw "Firebase CLI not found on PATH or in the user npm bin directory."
    }
}

& $firebasePath deploy --only hosting --config "firebase.game.json" --project crushgamedemo-bloop
