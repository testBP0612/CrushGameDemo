# 任務 27：虎爺大獎節奏重分配＋衝擊特效（Codex 執行）

> **Claude 開卡格式（依 2026-07-15 人類裁示，由 Codex 代筆）**。
> 依 `Docs/DECISIONS.md` **D-025**。
> 一句話：不改虎爺救援玩法，只把現行「反擊後立刻砸下、落地後反而空等」重排成
> **危機定格 → 神明降臨 → 落地爆點 → 大獎揭曉**四拍，並加入克制、H5 友善的
> 金色粒子與衝擊效果，讓事件讀起來像真正的 jackpot moment。

## 一、觀察基線（2026-07-15 實跑）

現行 `animation_timing.json > effects.huye_event` 的問題不是整段一律太快，而是重拍失衡：

- `slow_hold = 0.0`：怪物剎車後沒有懸念停頓。
- `huye_drop_duration = 0.12`：虎爺從出現到落地約 7 幀，近似突然貼上畫面。
- `impact_hold = 0.0`：命中後立刻進回彈／飛出，落地重量沒有被看見。
- `pre_banner_delay = 1.0`：爆點完成後反而空等過久，虎爺落地與獎勵揭曉脫節。
- 現有震屏足夠有力，但缺少「落地同一幀」的閃光、衝擊環與噴散層次。

本卡的目標是**重分配停頓**，不是把所有動畫等比例拖慢。

## 二、演出契約（定案，不可自行變更）

### Beat A — 危機定格（Anticipation）

1. 怪物反擊逼近後停在主角前，保持 D-022「玩家先相信自己要輸」的語意。
2. 畫面暗場照現行 dimmer；怪物停止後增加短暫 `slow_hold`。
3. 虎爺尚未落地前可出現少量向上漂浮的金色光屑，作為特殊事件預告。
4. 不得提前顯示勝利、x2、金幣或 banner，不得破壞延後揭示結果的契約。

### Beat B — 神明降臨（Descent）

1. 虎爺仍由畫面上方降至現行 impact position。
2. 下墜時間必須足以讓眼睛讀到移動軌跡；可加短金色拖尾／雲氣光屑。
3. 下墜曲線維持「前段蓄勢、末段加速」，不可改成輕飄飄的等速滑入。
4. 虎爺可做克制的 scale punch（小幅放大後回正），數值必須資料驅動。

### Beat C — 落地爆點（Impact）

落地同一拍同步：

1. 既有 `huye_appear` SFX 呼叫點不變，必須對齊真正 impact 幀。
2. 既有震屏保留；可調成「瞬間重擊＋衰減」但不得新增全域 time scale。
3. 新增短白金閃光、向外擴張的金色衝擊環、左右噴散的塵霧／火花。
4. 虎爺回彈後增加短 `impact_hold`，確保玩家看清虎爺已完成救援。
5. **禁止使用 `Engine.time_scale`**；狀態機、timer、BGM 與 Web audio 不得被全域暫停。

### Beat D — 大獎揭曉（Payoff）

1. 怪物照現行向左上旋轉縮小飛出；可加少量星屑／煙塵尾跡，但不可使用金幣尾跡。
2. 縮短飛出後的空等，讓事件爆點自然銜接 banner。
3. Banner 維持既有圖片與任意處點擊行為；intro 改為較清楚的 overshoot，並在出現時
   噴一次少量金色紙屑／彩帶。
4. Banner 關閉後才播放既有 `huye_coin_burst`，形成第二高潮；衝擊粒子不得搶先冒充獎勵金幣。

## 三、第一輪調校基準（全部寫入 JSON）

以下是人類同意方向後的**第一輪起始值**，實跑可微調，但若偏離超過約 30% 必須在完成回報說明：

| 欄位 | 現況 | 第一輪基準 |
|---|---:|---:|
| `slow_motion_rate` | 0.65 | 0.58 |
| `slow_hold` | 0.00 | 0.28 |
| `dimmer_fade` | 0.16 | 0.22 |
| `huye_drop_duration` | 0.12 | 0.28 |
| `impact_hold` | 0.00 | 0.22 |
| `huye_bounce_duration` | 0.22 | 0.28 |
| `monster_fly_duration` | 0.62 | 0.70 |
| `pre_banner_delay` | 1.00 | 0.55 |
| `banner_appear` | 0.24 | 0.30 |

調整意圖：把時間從「落地後空等」搬到「落地前懸念＋落地後確認」。整段只允許適度增長，
不能把低機率驚喜事件做成冗長不可跳過的過場。

## 四、特效實作邊界

1. 新增獨立 `Scripts/effects/huye_jackpot_fx.gd`（名稱可微調），由 presenter 呼叫；
   不把粒子邏輯繼續塞進 `battle_presenter.gd`。
2. 優先使用 Godot 程式元件（`CPUParticles2D`、`Line2D`、`Polygon2D`、Tween 或短命 Sprite）；
   **本卡不生成、不新增正式美術素材**，不動 `Art/ART_CONTRACT.md`。
3. 建議效果集合：
   - anticipation：少量金色漂浮光屑。
   - descent：短金色拖尾。
   - impact：白金閃光＋金色 shockwave＋火花／塵霧。
   - banner：少量金色紙屑／彩帶。
4. 所有數量、生命期、速度、尺度、透明度、顏色與時長放入
   `animation_timing.json > effects.huye_event.jackpot_fx`；`.gd` 不得硬寫調校值。
5. `jackpot_fx.enabled=false` 或 config 缺失時，完整回退為卡 24 現有視覺，流程不崩。
6. H5 效能上限：同時存活粒子建議不超過 100；全部 one-shot、自動釋放，事件後不得殘留節點。
7. 不新增新的 SFX/BGM event id；沿用卡 25/26 的 `huye_appear`、`huye_coin_burst`、
   `event_bgm.huye`。

## 五、不得改動

1. 不改資料設定的觸發機率（2026-07-17 人類調整為 16%）、force-trigger 語意、獨立 RNG、強制逆轉與 payout x2 計算。
2. 不改狀態機狀態、勝負廣播時機、收益更新點或 CoinBurst 數值。
3. 不改虎爺／banner 正式圖片與 UI 版面。
4. 不新增商店、轉蛋、額外獎勵或任何新玩法。

## 六、預計影響檔案

- `Data/animation_timing.json`
- `Scripts/battle/battle_presenter.gd`
- `Scripts/effects/huye_banner.gd`
- `Scripts/effects/huye_jackpot_fx.gd`（新增）
- `Docs/06_DATA_SCHEMA.md`
- `Codex/VALIDATION_CHECKLIST.md`

若實作判斷必須動到上述清單之外的 gameplay/state-machine 檔案，先停下寫
`Docs/OPEN_QUESTIONS.md`，不得自行擴卡。

## 七、驗收

1. `force_trigger=true` 實跑並錄影／連續關鍵幀，能清楚指出四拍：
   危機定格、下墜中段、落地爆點、banner 揭曉。
2. 人眼確認虎爺下墜可讀、impact 有重量、落地與 banner 無一秒死空氣。
3. 落地幀的震屏、`huye_appear`、閃光與衝擊環同步；缺音檔時視覺仍完整。
4. Banner 關閉後才出獎勵金幣，impact／banner 粒子不與 CoinBurst 混淆。
5. `jackpot_fx.enabled=false` 回歸卡 24 現況；移除整組 config 不崩、流程走完。
6. 連續 force-trigger 兩關：無 Tween、粒子、dimmer、虎爺或怪物 transform 殘留。
7. 桌面 Godot 與 H5 各實跑至少兩輪；H5 無明顯掉幀、console 無新 error。
8. 對照前後錄影：整體事件可略增長，但主要時間必須由 post-impact 空等移至 anticipation／impact。

## 完成後必須回報

依 `AGENTS.md` 格式，附第一輪基準與最終採用值對照、桌面／H5 關鍵幀、fallback 與連續觸發結果。
