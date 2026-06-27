# 任務 09：UI 進場微動畫與提示文字節奏

## 目標
讓 UI 出現時有**克制**的進場節奏感（淡入 + 輕微滑入 + 小幅 stagger），並讓戰鬥提示文字有**適當停頓**、符合遊戲節奏——不是「啪」一下硬切，也不浮誇彈跳。

## 必讀文件
`AGENTS.md`、`Docs/04_UI_SPEC.md`（狀態↔面板對應）、`Docs/05_ANIMATION_SPEC.md`、`Docs/06_DATA_SCHEMA.md`、`Docs/DECISIONS.md`。
參考既有手感慣例：`Scripts/effects/`（task 06 的 static + 容錯 + 資料驅動寫法）。

## 範圍
1. **面板進場微動畫**：BetPanel / DecisionPanel / SettlementPanel / Hud / TopBar 在「**從隱藏→顯示**」時播放淡入 + 從下方輕微上滑。
2. **群組 stagger**：HUD 三欄、結算面板內文等，可做輕微錯位依序出現。
3. **提示文字節奏**：BattleMessage（戰鬥訊息）出現時淡入，並有足夠停留時間可閱讀；連續訊息切換要有節奏、不可瞬閃。

## 時間參數（一律讀 `Data/animation_timing.json > ui`，禁止寫死）
- `panel_fade`：面板淡入時長。
- `panel_slide` / `panel_slide_offset`：上滑時長 / 位移像素。
- `entrance_stagger`：群組元素錯位間隔。
- `message_appear`：提示文字淡入時長。
- `message_hold`：提示文字最短停留時間（確保可讀）。

## 不做
- 不改玩法、數值、狀態流程、結算邏輯。
- 不接正式美術、不碰音效實作。
- 不做浮誇效果（大彈跳、旋轉、過長動畫）。要克制。
- 不改 `Data/*.json` 的 schema 結構（時間參數已預先備妥，直接用）。

## 實作要求（關鍵）
1. **只在「hidden→shown」轉變的瞬間播放進場動畫一次**。記錄上一次可見狀態，**不可**在每次 `_update_view()`/snapshot 更新都重播（否則按按鈕時面板會抖動）。這是本卡最重要的防呆。
2. 進場動畫**不阻塞輸入/狀態機**、可容錯（沿用 `Scripts/effects/` 的 static + null 檢查風格）。
3. 提示文字：出現淡入；若同一則訊息已顯示，數值更新不要重觸發淡入；切換到新訊息時才重播，並尊重 `message_hold`。
4. 動畫進行中不可破壞版面不變量（`Docs/04` §二之二：角色與操作 UI 不重疊）。

## 驗收方式（完成前在 Godot 跑 + 截圖/錄影）
- 各面板出現時有可感的淡入+上滑，但克制不浮誇。
- 連按下注 −/＋、快捷籌碼時，面板**不會反覆抖動**（證明只在 hidden→shown 觸發）。
- 戰鬥提示文字淡入、停留足夠可讀、切換有節奏。
- 改 `animation_timing.json` 的 `panel_fade`/`message_hold` 後效果明顯改變（證明資料驅動）。
- 整局閉環順暢、無卡頓、版面不重疊。

## 完成後必須回報
依 `AGENTS.md` 完成回報格式（含截圖或短錄影、改動的 ui 參數、如何確保只在 hidden→shown 觸發）。
