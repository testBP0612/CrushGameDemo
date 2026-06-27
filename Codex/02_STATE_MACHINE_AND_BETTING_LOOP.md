# 任務 02：狀態機與下注閉環

## 目標
實作 `03_STATE_MACHINE.md` 的完整狀態機骨架，並讓「下注 → 開始挑戰 → 判定勝敗 → 撤退/繼續/戰敗 → 結算回下注」的**資料閉環**可運作（演出可先極簡）。

## 必讀文件
`Docs/03_STATE_MACHINE.md`、`Docs/02_SYSTEM_SPEC.md`、`Docs/06_DATA_SCHEMA.md`。

## 範圍
- `Scripts/core/game_state_machine.gd`：實作所有狀態與轉移。
- `Scripts/battle/payout_calculator.gd`：`current_payout = floor(bet * multiplier_at(stage))`。
- `Scripts/battle/risk_resolver.gd`：依 `success_rate_at(stage)` 用 `randf()` 判定勝敗。
- 下注扣款、撤退加收益、失敗損失的餘額更新（先寫入記憶體，存檔在 05）。
- 建議 `Scripts/core/event_bus.gd`（信號解耦，見 03 第四節）。

## 不做
- 不做完整戰鬥演出（03 任務卡）與精緻 UI（04 任務卡）。
- 不做存檔/服務層（05 任務卡）。
- 不做特效/手感（06 任務卡）。

## 實作要求
1. 狀態與轉移**逐一對應** `03_STATE_MACHINE.md` 表格，命名一致。
2. 收益、成功率、上下限全部查 `DataLoader`，禁止寫死。
3. 達 `max_stage` 時走 `CLEAR_SETTLE`，不顯示「挑戰下一隻」。
4. 餘額不可變負數；下注前檢查 `balance >= bet`。
5. 暫以 print / 簡單 Label 顯示目前狀態與數值即可（UI 細節留 04）。

## 驗收方式
- 用臨時按鈕或鍵盤觸發可走完：下注→挑戰→（勝）→決策→繼續/撤退；（敗）→戰敗結算→回下注。
- `current_payout` 隨 stage 提升符合 `multiplier_curve`。
- 多次挑戰的勝率統計趨近 `success_rate_curve`（可粗略觀察）。
- 撤退後餘額 = 原餘額 − bet + payout；失敗後餘額 = 原餘額 − bet。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 格式。
