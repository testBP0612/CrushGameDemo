# 任務 21：每局隨機倍率盤——漸進成長 + 單調遞增（Codex 執行）

> 依 `Docs/DECISIONS.md` **D-019**（回應 Q-007）。固定倍率曲線玩兩次就背起來了；
> 本卡讓每局開出一張「本局盤」，玩家有「今天盤好不好」的判斷樂趣。
> **success_rate 完全不動**——各局期望值自然浮動是設計特色。
> 建議在任務 20 之後執行（20 已把所有倍率顯示改為讀快照，本卡換源時 UI 零改動）。

## 目標

每局下注確認時，以 `multiplier_curve` 為基準擲出本局專屬的倍率表：

1. **抖動漸進**：低關抖動小（穩）、高關抖動大（瘋），幅度隨關卡線性放大。
2. **強制單調遞增**：任何一關的倍率 ≥ 前一關 × `min_growth_ratio`，永不倒退。
3. **只揭示下一關**：UI 只在決策時顯示下一關倍率，不提供全曲線預覽（D-019 裁示）。

## 必讀

`AGENTS.md`（鐵則 1/6）、`Docs/DECISIONS.md` D-019、
`Scripts/core/data_loader.gd`（**倍率查表的唯一現行讀取點** `Data.multiplier_at(stage)`，
第 125–135 行——本卡真正要換源的地方）、
`Scripts/battle/payout_calculator.gd`（第 6 行呼叫 `Data.multiplier_at`，收益計算同源）、
`Scripts/core/game_state_machine.gd`（run 生命週期；`multiplier_at` 呼叫點第 343 行附近）、
`Scripts/core/game_controller.gd`（快照 → HUD/UI 資料流）、
`Data/game_balance.json`（multiplier_curve、payout.rounding）、
`Codex/20_DECISION_INFO_REVAMP.md`（若已完成：倍率顯示點清單）。

## 演算法（本局盤生成，下注確認時執行一次）

```
prev = base_multiplier_at_stage_0 (1.0)
for stage in 1..max_stage:
	base   = multiplier_curve[stage]
	t      = (stage - 1) / (max_stage - 1)            # 0 → 1
	jitter = lerp(jitter_pct_stage_1, jitter_pct_stage_max, t)
	rolled = base * randf_range(1 - jitter, 1 + jitter)
	final  = max(rolled, prev * min_growth_ratio)     # 單調遞增保底
	final  = round 到 round_decimals 位
	prev   = final
```

- 用獨立 `RandomNumberGenerator`（`randomize()` seed），**不可**與演出用隨機共用
  也不可影響 success_rate 擲骰的既有隨機流。
- 本局盤存在 state_machine 的 run 狀態裡，結算/重開局時重擲。

## 範圍

### 1. `Data/game_balance.json` 新增 `multiplier_random`
```json
"multiplier_random": {
  "_comment": "每局隨機倍率盤。enabled=false 時完全走 multiplier_curve 原值（回退路徑）。抖動隨關卡由 stage_1 線性放大到 stage_max。",
  "enabled": true,
  "jitter_pct_stage_1": 0.10,
  "jitter_pct_stage_max": 0.30,
  "min_growth_ratio": 1.15,
  "round_decimals": 2
}
```
（參數可依手感微調，但欄位齊備、程式全讀 json，禁止寫死。）

### 2. 本局盤的持有與接線（**指定架構，避免歧義**）
- **本局盤陣列由 `game_state_machine.gd` 持有**（run 狀態的一部分），下注確認（run
  開始）時生成；`enabled=false` → 本局盤 = 原曲線原值（**逐位一致**，回歸驗證路徑）。
- **`Data.multiplier_at(stage)`（data_loader.gd）保持原樣不動**——它是「基準曲線」
  查表，生成本局盤時當輸入用。
- 換源做法：state_machine 新增本局盤查詢（例如 `run_multiplier_at(stage)`），
  把自己與 `payout_calculator.gd` 對 `Data.multiplier_at` 的**執行期呼叫點**改走
  本局盤（payout_calculator 若是純函式，由呼叫端把本局倍率傳入亦可——擇一，
  但顯示與計算必須同源）。
- rounding 規則不變（`payout.rounding: floor`）。
- success_rate 查表、擲骰、狀態流程**零改動**。

### 3. 快照/顯示鏈
- 確認 HUD「目前賠率」與決策畫面「下一關 1 賠 N / 過關可得」全部反映本局盤
  （若任務 20 已完成，這裡應該不需要動 UI 程式——驗證即可）。
- **不新增**任何顯示全曲線的 UI。

## 不做
- 不動 `success_rate_curve`、不動判定與狀態機時序、不動結算規則。
- 不做每日同種子/公平性驗證/伺服器端擲骰（排行榜運氣成分變大已在 D-019 接受）。
- 不改場景版面（本卡理論上零 UI 版面改動；若發現需要動版面，停下登記 OPEN_QUESTIONS）。

## 實作要求
1. 參數全讀 `game_balance.json > multiplier_random`（鐵則 6）。
2. `enabled=false` 回退路徑必須實測：關掉後整局倍率與改動前完全一致。
3. 單調遞增是硬性質：任何 seed 下 `盤[n] > 盤[n-1]` 恆成立（寫個臨時迴圈打印
  100 局驗證，驗完移除或留在 tmp/）。
4. 收益計算仍 floor；顯示的倍率與計算用倍率必須同源（不可顯示一套、算一套）。

## 驗收
- 連開多局：每局下一關倍率不同；同局內重看同一關數值不變（盤只擲一次）。
- 低關浮動視覺上小、高關浮動大；100 局打印驗證單調遞增與抖動範圍。
- `enabled=false` → 與原固定曲線逐位一致（回歸）。
- 改 json 的 `jitter_pct_stage_max` / `min_growth_ratio` → 行為即變。
- 撤退/戰敗/通關結算金額與顯示倍率吻合（floor 檢查）。
- **H5 實機**：整局可玩、排行榜寫入正常。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 21」。

## 完成後必須回報
依 `AGENTS.md` 格式（附兩局不同倍率盤的對照截圖 + 100 局驗證打印摘要）。
