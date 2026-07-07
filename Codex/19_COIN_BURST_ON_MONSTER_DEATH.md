# 任務 19：怪物死亡爆金幣特效（Codex 執行）

> **技術路線已裁定（Claude 2026-07-07）**：用 **Tween 噴發式金幣 sprite**（程式生成
> `Sprite2D` + Tween 拋物線），**不用 GPUParticles/CPUParticles**。理由：與
> `Scripts/effects/` 既有模組（hit_flash / screen_shake / damage_number 全為 Tween）
> 風格一致、H5/WebGL 相容性最穩、可直接吃現成 `icon_coin.png`，不需新美術。

## 目標
怪物死亡演出時，從怪物位置向上噴出一把金幣，拋物線散落並淡出——強化「打贏＝賺錢」
的獎勵感。玩法、數值、狀態機時序完全不變。

## 必讀
`Codex/06_FEEL_AND_EFFECTS.md`（本卡是它的延伸，同一套鐵則）、
`Scripts/effects/damage_number.gd`（生成節點+Tween+自毀的既有慣例）、
`Scripts/battle/battle_presenter.gd`（掛載點 `play_monster_death()`，第 95 行附近）、
`Codex/VALIDATION_CHECKLIST.md` 通用段（ResourceLoader.exists 鐵則）。

## 範圍
1. **`Scripts/effects/coin_burst.gd`**（新檔）：
   - 靜態入口，例如 `CoinBurst.play(parent_layer, origin, stage)`。
   - 生成 N 枚金幣 `Sprite2D`（貼圖 `res://Assets/final/ui/icon_coin.png`），
     各自隨機初速向上噴出 → 受重力下落 → 淡出，結束後 `queue_free()` 自毀。
   - 每枚金幣的方向/縮放/延遲加少量隨機，避免整齊劃一。
2. **`Data/animation_timing.json`**：新增 `effects.coin_burst` 區塊，所有數值由此讀取
   （鐵則 6，禁止寫死），欄位建議：
   ```json
   "effects": {
     "coin_burst": {
       "count_base": 8,
       "count_per_stage": 1,
       "duration": 0.55,
       "spawn_stagger": 0.03,
       "launch_speed": 520.0,
       "spread_degrees": 70.0,
       "gravity": 1600.0,
       "scale_min": 0.6,
       "scale_max": 1.0,
       "fade_out": 0.20
     }
   }
   ```
   （數值可在實作時憑手感微調，但**欄位齊備、程式全讀 json**。）
3. **`Scripts/battle/battle_presenter.gd`**：`play_monster_death()` 開頭以
   fire-and-forget 觸發 `CoinBurst.play(damage_number_layer, monster.position, stage)`
   ——**不 await**，`monster_death_finished` 的發出時機不得改變。
   金幣數量 = `count_base + count_per_stage × 當前 stage`（越後期爆越多，獎勵感遞增）。

## 不做
- **不改任何 `Scenes/*.tscn`**（全程式生成，掛在既有 `DamageNumberLayer` 下，
  避開 D-006 目視門檻——但驗收仍要截圖）。
- 不用 GPUParticles/CPUParticles、不加新美術素材、不改 Art Contract / manifest。
- 不新增 SFX 事件（`monster_death` 既有事件已在 `game_controller.gd` 觸發，
  金幣聲未來併入該事件音檔即可；`Docs/SFX_PRODUCTION_LIST.md` 不動）。
- 不改判定、收益、狀態流程、版面。

## 實作要求（沿用任務 06 鐵則）
1. 所有數值讀 `animation_timing.json > effects.coin_burst`，禁止寫死。
2. **不阻塞**：特效 fire-and-forget，出錯或缺圖時整局流程照常完成。
3. 貼圖存在性用 `ResourceLoader.exists()`；缺 `icon_coin.png` → 靜默跳過特效
   （最多 push_warning），不崩（D-004）。
4. 金幣總存活時間（duration + fade_out + 最大 stagger）應短於死亡→轉場的節奏，
   且每枚金幣結束即自毀——不得殘留到下一隻怪物或下注畫面。

## 驗收
- 打死怪物：金幣從怪物位置噴出、拋物線散落、淡出；死亡動畫與後續轉場時序
  與現狀完全一致（前後對照）。
- 高 stage 金幣明顯多於 stage 1（count_per_stage 生效）。
- 改 json 的 count_base/duration → 效果即變（資料驅動實測）。
- 暫時改壞貼圖路徑重跑 → 無特效但整局可玩、不崩。
- 連打多局金幣無殘留（節點數不累積，可用 remote tree 或 print 檢查）。
- **H5 匯出實機**：特效正常顯示、無掉幀（附截圖）。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 19」。

## 完成後必須回報
依 `AGENTS.md` 格式（附編輯器 + H5 截圖，至少含一張低 stage、一張高 stage 爆金幣瞬間）。
