# 任務 19：怪物死亡爆金幣 → 吸入收益 UI → 數字跳動（Codex 執行）

> **技術路線已裁定（Claude 2026-07-07）**：用 **Tween 噴發/歸巢金幣 sprite**（程式生成
> `Sprite2D` + Tween），**不用 GPUParticles/CPUParticles**。理由：與 `Scripts/effects/`
> 既有模組（hit_flash / screen_shake / damage_number 全為 Tween）風格一致、
> H5/WebGL 相容性最穩、可直接吃現成 `icon_coin.png`，不需新美術。
> 吸附目標與座標系做法見下方「關鍵技術點」。

## 目標
怪物死亡時的三階段獎勵演出，玩法、數值、狀態機時序完全不變：

1. **噴發**：金幣從怪物位置向上噴出、拋物線散開。
2. **吸附**：短暫滯空後，金幣逐枚加速飛向 HUD 的**目前收益**欄位（`Hud/PayoutValue`
   粉色數字——怪死漲的是收益，不是餘額），到達時縮小消失。
3. **跳數**：**第一枚金幣抵達的瞬間**才開始收益數字 count-up（沿用既有
   `PayoutCountUp`），後續金幣陸續吸入時數字持續上跳——形成「金幣進帳」的因果感。

## 必讀
`Codex/06_FEEL_AND_EFFECTS.md`（本卡是它的延伸，同一套鐵則）、
`Scripts/effects/damage_number.gd` + `payout_count_up.gd`（既有慣例）、
`Scripts/battle/battle_presenter.gd`（`play_monster_death()`，第 95 行附近）、
`Scripts/ui/hud.gd`（`_update_payout_label`，第 53–66 行——跳數延遲要改這裡）、
`Scripts/core/game_controller.gd`（`_play_presentation_for_state` / `_update_view`，
狀態→快照→HUD 的既有資料流）、
`Codex/VALIDATION_CHECKLIST.md` 通用段（ResourceLoader.exists 鐵則）。

## 關鍵技術點（先讀懂再動手）

1. **座標系**：戰場是 Node2D canvas（1080×1920），HUD 是 Control。**建議金幣生在
   程式建立的專用 `CanvasLayer`（screen space）**：起點 = 怪物
   `get_global_transform_with_canvas().origin`，終點 = `PayoutValue`
   `get_global_transform_with_canvas()` 中心——兩者同空間，免去逆轉換。
   （若你選擇留在 DamageNumberLayer 世界空間，就要做 canvas transform 逆轉換，
   目視確認終點真的落在收益數字上。）
2. **跳數延遲與保底**：現況是快照一到 `hud.gd` 立即 count-up。改為：HUD 提供
   「暫扣」API（例如 `hold_payout_count_up()` / `release_payout_count_up()`）——
   MONSTER_DEATH 演出開始時由 game_controller 暫扣，第一枚金幣抵達的 callback 放行。
   **必須有保底 timeout**（讀 json 的 `max_hold`）：即使特效失敗/缺圖/callback 沒來，
   時間到數字照樣跳——**顯示值永遠不可停在舊數**。內部 `state_machine` 數值完全不動，
   延遲的只是「視覺」。
3. **不阻塞**：`monster_death_finished` 的發出時機不得改變；金幣飛行可以跨進
   TRANSITION 狀態（視覺上無妨），但每枚到達即自毀，不殘留。

## 範圍
1. **`Scripts/effects/coin_burst.gd`**（新檔）：
   - 入口例如 `CoinBurst.play(origin_canvas_pos, target_canvas_pos, stage, on_first_arrival: Callable)`。
   - 噴發（隨機初速+重力）→ 滯空 `hover_time` → 逐枚（`fly_stagger`）Tween 加速飛向
     目標，到達縮小+淡出+`queue_free()`；第一枚到達時呼叫 `on_first_arrival`。
   - 金幣數 = `count_base + count_per_stage × stage`。
2. **`Data/animation_timing.json`**：新增 `effects.coin_burst` 區塊，所有數值由此讀
   （鐵則 6，禁止寫死），欄位建議：
   ```json
   "effects": {
     "coin_burst": {
       "count_base": 8,
       "count_per_stage": 1,
       "burst_duration": 0.40,
       "spawn_stagger": 0.03,
       "launch_speed": 520.0,
       "spread_degrees": 70.0,
       "gravity": 1600.0,
       "hover_time": 0.10,
       "fly_duration": 0.35,
       "fly_stagger": 0.04,
       "scale_min": 0.6,
       "scale_max": 1.0,
       "arrive_fade": 0.08,
       "max_hold": 1.2
     }
   }
   ```
   （數值可實作時憑手感微調，但**欄位齊備、程式全讀 json**。）
3. **`Scripts/ui/hud.gd`**：跳數暫扣/放行 API（見技術點 2）；並暴露收益欄位的
   canvas 座標（例如 `payout_anchor_canvas_position()`）供 controller 取用。
4. **`Scripts/core/game_controller.gd`**：MONSTER_DEATH 演出時串線——暫扣跳數、
   把 HUD 目標座標交給特效、以 arrival callback 放行。fire-and-forget，不 await。
5. **`Scripts/battle/battle_presenter.gd`**：提供怪物當前 canvas 座標（或由
   controller 直接取 `monster.get_global_transform_with_canvas()`），死亡演出本身不改。

## 不做
- **不改任何 `Scenes/*.tscn`**（CanvasLayer 與金幣全程式生成——避開 D-006 盲改
  門檻，但驗收仍要截圖）。
- 不用 GPUParticles/CPUParticles、不加新美術素材、不改 Art Contract / manifest。
- 不新增 SFX 事件（`monster_death` 既有事件已涵蓋；金幣聲未來併入該事件音檔；
  `Docs/SFX_PRODUCTION_LIST.md` 不動）。
- 不改判定、收益數值、狀態流程、版面；不動餘額（BalanceLabel）——吸附目標是
  **目前收益**。

## 實作要求（沿用任務 06 鐵則）
1. 所有數值讀 `animation_timing.json > effects.coin_burst`，禁止寫死。
2. **不阻塞**：特效出錯/缺圖時整局流程照常，跳數靠 `max_hold` 保底照常發生。
3. 貼圖 `res://Assets/final/ui/icon_coin.png` 存在性用 `ResourceLoader.exists()`；
   缺圖 → 靜默跳過特效（最多 push_warning）、跳數立即放行，不崩（D-004）。
4. 每枚金幣到達即自毀；連打多局節點數不累積。

## 驗收
- 打死怪物：噴發 → 吸入收益欄 → **數字在第一枚金幣到達時才開始跳**（錄影或連續截圖
  佐證因果順序）；死亡動畫與後續轉場時序與現狀一致（前後對照）。
- 金幣終點確實落在收益數字上（含 H5 實機——縮放後座標轉換最容易在這裡露餡）。
- 高 stage 金幣明顯多於 stage 1；改 json 的 count_base/fly_duration → 效果即變。
- 暫時改壞貼圖路徑重跑 → 無特效但數字照跳（max_hold 保底）、整局可玩不崩。
- 連打多局金幣無殘留（remote tree 或 print 檢查節點數）。
- **H5 匯出實機**：特效正常、無掉幀（附截圖）。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 19」。

## 完成後必須回報
依 `AGENTS.md` 格式（附編輯器 + H5 截圖；至少一張爆發瞬間、一張吸附中途、
一張低/高 stage 對比）。
