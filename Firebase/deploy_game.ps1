# deploy_game.ps1 — 部署遊戲本體到 Firebase Hosting（D-015 / 任務 13）
# 前提：已在 Godot 完成 Web export 至 export/web/（preset "Web"）。
# 用法：在 Firebase/ 目錄執行 .\deploy_game.ps1
$ErrorActionPreference = "Stop"
$exportDir = Join-Path $PSScriptRoot "..\export\web"

if (-not (Test-Path (Join-Path $exportDir "index.html"))) {
    Write-Error "export/web/index.html 不存在——先在 Godot 用 Web preset 匯出。"
}

# 橋接與設定檔隨附部署（export 不會自帶）
Copy-Item (Join-Path $PSScriptRoot "public\config.js") $exportDir -Force
Copy-Item (Join-Path $PSScriptRoot "web\crush-online.js") $exportDir -Force

firebase deploy --only hosting --config (Join-Path $PSScriptRoot "firebase.game.json") --project crushgamedemo-bloop
