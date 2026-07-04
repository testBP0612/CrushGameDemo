# deploy_game.ps1 - deploy the game build to Firebase Hosting (D-015 / task 13)
# Prereq: Godot Web export done to export/web/ (preset "Web").
# Usage: run from anywhere; paths are script-relative.
# NOTE: keep this file ASCII-only — PowerShell 5.1 misreads BOM-less UTF-8.
$ErrorActionPreference = "Stop"
$exportDir = Join-Path $PSScriptRoot "..\export\web"

if (-not (Test-Path (Join-Path $exportDir "index.html"))) {
    Write-Error "export/web/index.html not found - export from Godot (Web preset) first."
}

# Bridge + config are not part of the Godot export; ship them alongside.
Copy-Item (Join-Path $PSScriptRoot "public\config.js") $exportDir -Force
Copy-Item (Join-Path $PSScriptRoot "web\crush-online.js") $exportDir -Force

# hosting.public must live under the config file's directory, so the game
# deploy config sits at repo root (firebase.game.json) with public=export/web.
Set-Location (Join-Path $PSScriptRoot "..")
firebase deploy --only hosting --config "firebase.game.json" --project crushgamedemo-bloop
