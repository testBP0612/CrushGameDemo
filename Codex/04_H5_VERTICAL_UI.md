# 任務 04：H5 直式 UI

## 目標
依 `04_UI_SPEC.md` 完成 9:16 直式正式 UI：HUD、下注面板、決策雙按鈕，並依狀態機正確顯示/啟用。

## 必讀文件
`Docs/04_UI_SPEC.md`、`Docs/03_STATE_MACHINE.md`（UI 狀態對應）、`Docs/06_DATA_SCHEMA.md`（ui_text）。

## 範圍
- `Scenes/UI/` 場景 + `Scripts/ui/` 控制：`Hud`、`BetPanel`、`DecisionPanel`、`BattleMessage`、`SettlementPanel`（結算面板的資料邏輯留 05，本卡先做外觀與顯示切換）。
- HUD：關卡 `stage/max`、倍率、目前收益、金幣餘額（文案 key 見 ui_text）。
- 下注面板：−/＋（受 min/max/step 限制）、開始挑戰（餘額不足禁用 + 顯示 `bet_insufficient`）。
- 決策面板：撤退領取（帶入即時 payout）、挑戰下一隻；達 max 時隱藏「挑戰下一隻」。
- 所有面板的顯示/隱藏/可互動依狀態機（建議訂閱 EventBus）。

## 不做
- 不做底部 Tab Bar、商店、設定、成就、常駐資源列（見不做清單）。
- 不改數值邏輯。
- 不接正式美術（UI 用 Godot 內建 Control 樣式即可）。

## 實作要求
1. 用 anchors 適應 9:16 安全區，桌機/行動皆不溢出。
2. 文字一律 `text(key, vars)`，禁止寫死中文。
3. 按鈕熱區足夠大（觸控友善）。
4. UI 不直接讀狀態機內部變數，透過事件/介面取值。

## 驗收方式
- 各狀態只顯示對應面板（對照 03 的「UI 狀態對應」）。
- −/＋ 受上下限與步進限制；餘額不足時開始挑戰禁用。
- 撤退按鈕文字即時反映 `current_payout`。
- 視窗縮放（模擬手機）UI 正常。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 格式。
