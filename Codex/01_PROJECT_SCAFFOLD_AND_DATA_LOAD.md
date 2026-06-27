# 任務 01：專案骨架與資料載入

## 目標
建立 9:16 H5 專案骨架、主場景、資料載入器，讓遊戲能啟動、讀完所有 `Data/*.json`、進入 TITLE 畫面。

## 必讀文件
`Codex/00_MASTER_PROMPT.md`、`Docs/04_UI_SPEC.md`（畫布設定）、`Docs/06_DATA_SCHEMA.md`、`Docs/07_H5_EXPORT_SPEC.md`、`Docs/03_STATE_MACHINE.md`（BOOT/TITLE）。

## 範圍
- 設定 `project.godot`：9:16（1080×1920）、`stretch/mode=canvas_items`、`aspect=keep`。
- 建立 `Scenes/Main.tscn` + `Scripts/core/game_controller.gd`（作為入口）。
- 建立 `Scripts/core/data_loader.gd`：啟動時載入 5 個 JSON，提供查表 API（見 06）。
- 建立最小 `TitleScreen`，顯示 `title_game_name` 與 `best_record`（暫可 0）。
- 建立 `Assets/placeholders/` 必要暫代資源（或以 ColorRect 程式生成）。

## 不做
- 不做戰鬥、下注、UI 互動細節（後續任務卡）。
- 不接正式美術。
- 不做狀態機完整轉移（只到 BOOT→TITLE）。

## 實作要求
1. `DataLoader` 解析失敗要明確報錯（push_error），不可靜默。
2. 提供 API：`text(key, vars)`, `balance_config()`, `multiplier_at(stage)`, `success_rate_at(stage)`, `monster_for_stage(stage)`。
3. 所有顯示文字透過 `text()` 取得，**禁止寫死中文**。
4. 設定設定檔讓 Web export 可行（範本可後續裝，但 preset/設定先到位）。

## 驗收方式
- 執行專案不報錯，顯示標題畫面（直式置中）。
- 在 `_ready` 或除錯輸出能印出讀取到的 `starting_balance` 與第 1 關 `multiplier`/`success_rate`，數值與 JSON 一致。
- 改 `Data/game_balance.json` 的 `default_bet` 後重啟，程式讀到新值（證明非寫死）。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 的「完成回報」格式。
