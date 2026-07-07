# 任務 20：決策資訊賭場化改版——拿血條、危險度、賠率語言、FOMO 結算（Codex 執行）

> 依 `Docs/DECISIONS.md` **D-019**（回應 Q-007）。核心精神：把玩家注意力從「假戰鬥」
> 移回「真賭注」——**放大獎金、隱藏機率、風險質化**。玩法、判定、數值、狀態機時序
> 完全不變，本卡只動「資訊怎麼呈現」。
>
> **文案契約（本卡最重要的鐵則）**：所有句子先按博奕術語寫入 `Data/ui_text.json`
> （下方附初稿），**人類會事後直接改 json 換句子**——程式只認 key 與 `{變數}` 佔位符，
> 不得依賴字串內容、長度、標點做任何邏輯或排版假設。

## 目標

1. **拿掉血條**：`MonsterHpBar` 不再顯示；原位置改為**危險度指示**（等級圖示，
   依該關 success_rate 資料驅動分級）。
2. **決策畫面賠率語言**：主視覺是「過關可得 {金額}」（直接算好的金額最有感），
   副標「1 賠 {倍率}」；撤退按鈕語言=「落袋為安」。**不顯示成功率 %**。
3. **結算 FOMO 事後揭示**：撤退成功顯示「若再過一關可得 {金額}…」；戰敗顯示
   「上一關落袋本可帶走 {金額}…」。

## 必讀

`AGENTS.md`（鐵則 6/8）、`Docs/DECISIONS.md` D-019 + D-006（版面需 Godot 目視）、
`Scripts/battle/battle_presenter.gd`（`$MonsterHpBar` 第 26 行、`style_monster_status`
第 35 行、血量演出邏輯 52–158 行——**內部邏輯保留**）、
`Scripts/ui/ui_skin.gd`（`style_monster_status`）、
`Scripts/ui/decision_panel.gd`（決策按鈕與文字組裝——`_cashout_is_art`/`_advance_is_art`
分支第 20–32 行：圖片按鈕不設字、缺圖 fallback 才用 `Data.text(...)`，本卡改的是
fallback 分支與周邊資訊 Label，不動圖片按鈕邏輯）、
`Scripts/ui/hud.gd` + `Scripts/core/game_controller.gd` +
`Scripts/core/game_state_machine.gd`（決策畫面資料流與 snapshot）、
`Scripts/ui/settlement_panel.gd`（結算文案組裝慣例：Data.text + RichTextLabel bbcode）、
`Data/game_balance.json`（success_rate_curve、multiplier_curve）。

## 範圍

### 1. 血條 → 危險度（`battle_presenter.gd` + 場景 + `ui_skin.gd`）
- `MonsterHpBar` **隱藏**（`visible = false` 或場景中移除顯示；**血量演出的內部計算
  與傷害節奏完全保留**——死亡時機、hit 節奏都依賴它，只是不給玩家看）。
- 原位置改放危險度顯示：怪物名 + 危險度圖示列（建議沿用現有貼紙 icon，如爪印/骷髏，
  用 `ResourceLoader.exists()` 判斷；缺圖 fallback 為文字「危險度 ★×N」樣式的 Label）。
- 等級來源：`game_balance.json` 新增 `danger_display`（見下方 schema），依**即將挑戰
  關卡**的 success_rate 落點對映 1–5 級。禁止在程式寫死門檻（鐵則 6）。
- 顏色建議由 UiSkin 統一：低危綠 → 高危紅（可與等級一起入 json）。

### 2. `Data/game_balance.json` 新增 `danger_display`
```json
"danger_display": {
  "_comment": "危險度分級（取代血條）。依即將挑戰關卡的 success_rate 由上往下取第一個符合的等級。",
  "max_level": 5,
  "levels": [
	{ "min_success_rate": 0.80, "level": 1 },
	{ "min_success_rate": 0.60, "level": 2 },
	{ "min_success_rate": 0.45, "level": 3 },
	{ "min_success_rate": 0.30, "level": 4 },
	{ "min_success_rate": 0.00, "level": 5 }
  ]
}
```
（門檻數值可依手感微調，但欄位齊備、程式全讀 json。）

### 3. 決策畫面（decision 狀態的資訊區）
- 新增/改造資訊列（主 → 副）：
  1. **過關可得 {payout}**（主視覺，最大字，= 下一關倍率 × 本局下注後直接算好的金額）
  2. **下一關 1 賠 {multiplier}**（副標）
  3. 危險度圖示（承範圍 1，決策時同樣要看得到）
- **快照新增下一關欄位（本卡明確授權的唯一 core 改動）**：現行 snapshot 只有
  `current_multiplier`/`current_payout`（已清關那一關），**沒有**下一關的值。
  在 `game_state_machine.gd`/`game_controller.gd` 新增 `next_stage_multiplier` 與
  `next_stage_payout`（= `Data.multiplier_at(stage + 1)` × 本局下注，floor；
  已在最終關則為空/哨兵值，UI 隱藏對應資訊列）。
- UI 端倍率/金額**一律取自 state 快照**，不得自己讀 `multiplier_curve` 算——任務 21
  會把倍率來源換成「本局隨機盤」（只改快照欄位的來源函式），讀快照的 UI 屆時零改動。
- `decision_advance` / `decision_cashout` 按鈕：next/retreat.png 是**烙字素材**，
  圖上文字不動（要換走 Q-ART）；本卡只改 json 內的 fallback 文字與周邊資訊 Label。

### 4. 結算 FOMO 行（`settlement_panel.gd`）
- 撤退成功：現有 stats 區下方加一行 `settle_cashout_fomo`（需要「下一關倍率」——
  同樣走快照/服務接口取，撤退當下下一關若不存在〔已通關〕則**整行隱藏**）。
- 戰敗：加一行 `settle_defeat_fomo`（= 上一關撤退可得的金額；第 1 關就戰死
  〔無上一關收益〕則**整行隱藏**）。
- 完美通關（clear）不加 FOMO 行。
- 排版沿用現有結算面板慣例（RichTextLabel + Data.text 代入），金額可用既有粉色
  highlight 慣例。

### 5. `Data/ui_text.json` 新增/修訂 key（**博奕術語初稿，人類會再改**）
```json
"hud_multiplier": "目前賠率 1 賠 {multiplier}",

"monster_danger_caption": "危險度",
"monster_danger_fallback": "危險度 {stars}",

"decision_next_win": "過關可得 {payout}",
"decision_next_odds": "下一關 1 賠 {multiplier}",
"decision_advance": "過關",
"decision_cashout": "落袋為安 {payout}",

"settle_cashout_fomo": "若再過一關，可得 {next_payout}…",
"settle_defeat_fomo": "上一關落袋，本可帶走 {payout}…"
```
- 既有 key 只**修訂內容**不改名（改名會斷其他呼叫點）；新 key 命名照現有慣例。
- 舊 `decision_cashout`「撤退領取 {payout}」直接以新句取代。

## 不做
- 不改判定、成功率、倍率數值、狀態機時序；不動 `battle_presenter` 的傷害/死亡節奏。
- **不顯示成功率百分比**——任何形式都不出現（這是 D-019 的核心裁示）。
- 不換 next/retreat.png 按鈕素材、不改 Art Contract / manifest（若判斷烙字與新文案
  衝突到不可接受，登記 Q-ART 停下來問）。
- 不做倍率隨機化（任務 21）；不加 SFX。

## 實作要求
1. 所有門檻/等級讀 `game_balance.json > danger_display`，所有句子讀 `ui_text.json`。
2. 危險度 icon 缺圖 → fallback 文字 Label，不崩（D-004）。
3. 版面調整遵守 `Docs/04` 版面不變量（操作 UI y≥1300、不壓角色）；**任何場景改動
   必須 Godot 內目視確認**（D-006），驗收附截圖。
4. FOMO 行的邊界條件（通關無下一關、第 1 關戰死）整行隱藏，不出現空佔位符。

## 驗收
- 血條不再顯示；戰鬥演出節奏（hit/死亡時機）與現狀逐幀一致（前後對照）。
- 危險度隨關卡遞增（第 1 關 1 級 → 第 10 關 5 級）；改 json 門檻 → 分級即變。
- 決策畫面：金額主視覺 + 1 賠 N 副標 + 危險度，無任何 % 字樣。
- 撤退結算出現「若再過一關…」且金額正確（= 收益 × 下一關倍率，floor）；
  通關結算無此行；第 1 關戰死無「上一關落袋…」行。
- 改 `ui_text.json` 任一句 → 畫面即變（證明無寫死）。
- **H5 實機**：直式版面不變量成立，附截圖。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 20」。

## 完成後必須回報
依 `AGENTS.md` 格式（附編輯器 + H5 截圖：決策畫面、危險度高低關對比、
兩種結算 FOMO 行）。
