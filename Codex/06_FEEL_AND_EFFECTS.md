# 任務 06：手感與效果

## 目標
在不改變玩法與數值的前提下，加入讓戰鬥更有感的效果：hit flash、輕微畫面震動、按鈕回饋、撤退/戰敗特效、收益跳動。

## 必讀文件
`Docs/05_ANIMATION_SPEC.md`（第五節手感）、`Docs/06_DATA_SCHEMA.md`（animation_timing.ui）。

## 範圍
- `Scripts/effects/`：`hit_flash.gd`、簡單 camera/畫面 shake、`payout_count_up`（收益數字跳動）。
- 按鈕點擊回饋（縮放/顏色，時長取 `animation_timing.ui.button_feedback`）。
- 撤退成功 / 戰敗 的簡單特效（粒子或 Tween 皆可，placeholder 等級）。

## 不做
- 不改判定、收益、狀態流程。
- 不接正式美術。
- 不加音效（除非 `OPEN_QUESTIONS Q-002` 定案要做，且僅非關鍵點擊音）。

## 實作要求
1. 所有效果時長讀 `animation_timing.json`，禁止寫死。
2. 效果為**可關閉/不阻塞**：即使效果出錯也不能卡住狀態機流程。
3. 效果模組化置於 `Scripts/effects/`，由事件觸發，不污染 battle/core 邏輯。

## 驗收方式
- 怪物受擊有 flash + 輕震；按鈕點擊有回饋。
- 撤退/戰敗有可辨識的結算特效。
- 收益數字有跳動動畫（count up）。
- 關閉效果（或效果報錯模擬）時，遊戲流程仍正常完成。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 格式。
