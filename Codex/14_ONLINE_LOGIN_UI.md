# 任務 14：線上登入 UI（Codex 執行：UI 生成 + 場景擺位 + 目視驗證）

> **前置**：任務 13 的程式串接已由 Claude 完成（分工經人類 2026-07-04 指示：串接=Claude、UI=Codex）。
> 本卡只做 UI：生成素材、擺位、接訊號。**不改 services/core 的邏輯。**

## 目標
玩家在標題畫面能 Google 登入/登出；登入後 TopBar 顯示玩家名與雲端同步標記。未登入時遊戲照常可玩（本機模式），UI 不得暗示「必須登入」。

## 必讀文件
`AGENTS.md`、`Docs/08_ONLINE_SCORE_SPEC.md`（fallback 契約）、`Docs/04_UI_SPEC.md`（§二之一座標契約、§二之二版面不變量）、`Docs/DECISIONS.md`（D-006、D-012、D-015）、`Assets/ART_ASSET_MANIFEST.md`（UI 素材段）、`Art/references/ui_target_*.png`（視覺目標）。

## 程式接點（已存在，直接用）
- `game_controller.score_service`（`OnlineScoreService`）：
  - `is_online_available() -> bool`：false = 非 Web 或橋接缺失，**整組登入 UI 隱藏**。
  - `is_signed_in() -> bool`、`online_display_name() -> String`
  - `sign_in()` / `sign_out()`
  - signal `auth_changed(signed_in: bool, display_name: String)`
  - signal `cloud_merged()`（登入合併完成，可做一次輕量提示）
- 注意：`sign_in()` 會開 OAuth popup，**必須由使用者點擊直接觸發**（瀏覽器手勢要求），不可由程式自動呼叫。

## UI 範圍（三件事）
1. **標題畫面登入鈕**：`TitleScreen` 的 `TitleLayout` 內、StartButton 下方。
   - 未登入顯示 `text.login_button`；已登入顯示 `text.logout_button`。
   - 樣式：沿用 `ui_skin.gd` 的 secondary 按鈕（`skin_btn_secondary` 皮膚）+ icon 貼紙 `icon_login`。
2. **TopBar 登入狀態**：`ProfileFrame` 內。
   - 已登入：`ProfileLabel` 改顯示 `online_display_name()`（動態資料，非寫死文案）+ 貼紙 `icon_cloud`。
   - 未登入：維持現狀（mock 名稱），不顯示 `icon_cloud`。
3. **`ui_text.json` 新增 key**（文案禁止寫死）：
   - `login_button`（建議：「Google 登入」）、`logout_button`（「登出」）、
     `login_hint_synced`（「已同步雲端」，cloud_merged 時短暫顯示，可選）。

## 需生成的美術素材（依 D-012 產線：全尺寸母檔 + runtime 48px）
| asset_id | 用途 | 風格錨點 |
|---|---|---|
| `icon_login` | 登入鈕貼紙 | 貓鈴鐺或貓項圈；奶白+深藍厚描邊、貼紙感，同 `icon_paw` 等現有 icon 一致 |
| `icon_cloud` | 已同步標記 | 小雲朵（可帶魚形雨滴梗）；同上風格 |
- 檔名/路徑照 manifest 慣例：`Assets/final/ui/<id>.png` + `runtime/<id>_48.png`，完成後更新 manifest 表格。
- **缺圖不崩**：icon 缺檔時按鈕仍可用（只是沒貼紙），沿用 ui_skin 的 fallback 寫法。

## 不做
- 不做排行榜/好友/頭像下載（Google 頭像 URL 不接，只用 display_name）。
- 不改 `Scripts/services/`、`Scripts/core/` 邏輯（接訊號可以，改行為不行）。
- 不在遊戲進行中（非 BETTING/標題）顯示登入prompt。

## 驗收方式
- 桌面編輯器：`is_online_available()` = false → 登入 UI 完全隱藏，版面與現狀一致（截圖）。
- H5（`Firebase/deploy_game.ps1` 部署後實機）：登入鈕點擊 → popup → 登入成功 → TopBar 顯示名稱與 icon_cloud；登出恢復。
- 版面不變量（Docs/04 §二之二）不破壞；**Godot 內目視確認並截圖**（D-006）。
- 文案全部來自 `ui_text.json`（改 json 重啟即變）。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 13/14」相關項。

## 完成後必須回報
依 `AGENTS.md` 格式，附桌面/H5 兩種截圖。
