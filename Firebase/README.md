# Firebase 操作手冊（給任何接手的 AI 與人類）

> 目的：讓你不用重新摸索就能**部署、測試、驗證** Firebase 相關變更。
> 2026-07-05 由 Claude 建立（依實戰經驗）。環境事實過期時請實測後更新本檔。

## 環境事實（2026-07-05）

- Firebase CLI 已全域安裝且**已登入**（sp112131@gmail.com）。專案：`crushgamedemo-bloop`（Spark 免費方案，asia-east1）。
- **這台機器沒有 Java → Firebase Emulator 不可用。不要為此安裝 JDK**（見下方測試策略；若真有需要先問人類）。
- Godot 4.6.3 無頭匯出可用：
  ```powershell
  & "C:\Users\User\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe" `
    --headless --path E:\CrushGameDemo --export-release "Web" "export/web/index.html"
  ```

## 鐵則

1. **部署免授權**（人類 2026-07-05 裁示：比賽 demo 專案，rules 與 hosting 可自行部署）。
   若本專案日後轉正式營運，此條需重新裁示。
2. 登入/憑證動作由人類親手完成，AI 不經手密碼/token。
3. web config（apiKey 等）是公開設計可進 repo；**私鑰/service account 絕不可**。

## 測試策略：用真環境，不用 Emulator

本專案規模下，rules 測試直接打**已部署的真專案**（免費、即時、測的是真行為）：

- **部署 rules**：`cd E:\CrushGameDemo\Firebase; firebase deploy --only "firestore:rules" --project crushgamedemo-bloop`
- **未登入該被拒**（期望 HTTP 403）：
  ```powershell
  Invoke-RestMethod -Uri "https://firestore.googleapis.com/v1/projects/crushgamedemo-bloop/databases/(default)/documents/<collection>/<doc>" -Method Get
  ```
- **已登入案例**：開 https://crushgamedemo-bloop.web.app （瀏覽器已登入的 session 會自動還原），
  在 DevTools console 直接呼叫橋接 API 驗證，例如：
  ```js
  CrushOnline.fetchLeaderboard(10, (s) => console.log(s));
  CrushOnline.save(999, 1234);   // users/ 自寫測試
  ```
  歷史前例：`Firebase/public/index.html` 是 D-015 的驗證頁（登入/寫入/讀回三鍵），可仿製。
- **跨帳號案例**（跨 uid 寫入被拒）需要第二個 Google 帳號，通常以 rules 結構審查代替，誠實標註未實測。

## 部署遊戲本體（打包 → 上線）

1. Godot 無頭匯出（上面指令；或編輯器內用 Web preset 匯出到 `export/web/`）。
2. `cd E:\CrushGameDemo\Firebase; .\deploy_game.ps1`
   （腳本會把 `public/config.js` 與 `web/crush-online.js` 複製進 export 再 deploy——
   這兩檔不在 Godot 匯出物內，漏了會整組登入失效。）
3. 驗證時瀏覽器要 **Ctrl+Shift+R 硬刷新**（wasm/pck 快取很頑固）。

## 檔案地圖

| 檔案 | 作用 |
|---|---|
| `Firebase/firebase.json` | 測試頁 hosting（public=`Firebase/public/`）+ rules 路徑 |
| `E:\CrushGameDemo\firebase.game.json`（repo root） | **遊戲**hosting（public=`export/web`）。在 root 是因為 hosting public 必須位於 config 所在目錄之下 |
| `Firebase/firestore.rules` | 唯一 rules 正本（users/ + leaderboard/） |
| `Firebase/web/crush-online.js` | Godot↔Firebase 橋接**正本**；`Firebase/public/` 內的是測試頁副本，改動要同步 |
| `Firebase/deploy_game.ps1` | 遊戲部署腳本（**保持 ASCII-only**：PS 5.1 會誤讀無 BOM 的 UTF-8 中文註解） |

## 已踩過的坑（改動前先讀）

- `FileAccess.file_exists()` 在匯出版對 imported 資源恆 false → 用 `ResourceLoader.exists()`（詳見 `Codex/VALIDATION_CHECKLIST.md` 通用段）。
- Web export 必須**關 thread support**（D-015：COOP/COEP 會擋 OAuth popup）。preset 已設好，別開回來。
- `signInWithPopup` 必須由使用者真實點擊觸發；程式化點擊開不了 popup（安全機制，非 bug）。
- hosting 部署報「outside of project directory」= public 目錄不在 config 檔目錄底下。
