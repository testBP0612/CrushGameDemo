# 任務 24：「遇見虎爺」隨機救援事件（Codex 執行）

> 依 `Docs/DECISIONS.md` **D-022**（2026-07-11 人類裁示）。
> 一句話：玩家「明明要輸了」的那一刀變成超慢動作——虎爺天降壓飛怪物，逆轉為勝，
> 該關增額翻倍，配博奕遊戲 FREE GAME 式的大字插頁與虎爺對話框。
> 戲劇核心是**絕望→逆轉**：演出順序不能劇透，玩家要先相信自己輸了。
>
> **工作方式**：機制契約與演出分鏡如下文；具體手法（tween 寫法、節點結構、
> signal 命名）不設限，你自行決定，但每個演出參數都要進 json、每張圖都要有
> fallback。視覺效果要在實際跑起來的遊戲裡目視確認（D-006 / D-021 均可）。

## 一、機制契約（這部分是定案，不可自行變更）

1. **觸發擲骰**：每次發起挑戰（下注確認與續戰各算一次）擲一次，機率讀
   `game_balance.json > random_events.huye.trigger_probability`（初值 0.05）。
   **用專屬 `RandomNumberGenerator`**（仿卡 21 的 `_rng`，`game_state_machine.gd:65`），
   不得共用 risk_resolver 的全域 `randf()` 流、也不得共用倍率盤 `_rng`——
   三條隨機流互不影響是硬需求。
2. **強制逆轉勝**：骰中虎爺的那一關，`finish_attack()`（`game_state_machine.gd:131-144`）
   無視 `_risk_resolver.resolve()` 結果，判定為**勝**。「照常前進」指的是**進度語意**
   （算過關、進 REWARD_DECISION、倍率照走）；**動畫路徑不照常**——不播正常勝利的
   monster_hurt/death 演出，改走 §二的虎爺逆轉演出（以敗局反擊開場）。勝局如何
   借用反擊分支開場、狀態/signal 怎麼接，由你設計。
   （實作上骰不骰 risk_resolver 都行，但若照骰請確認不影響其骰序列的可重現性——
   最省事就是虎爺關跳過 resolve。）
   **劇透陷阱**：現況 `finish_attack` 會立即 `result_resolved.emit(is_win)`；虎爺局
   若照發 true，任何對勝利即時反應的監聽者（訊息、UI）都會在逆轉演出前洩底。
   虎爺局的勝負廣播須延後到虎爺現身之後（或改道），「玩家先相信自己輸了」是硬需求。
3. **該關增額翻倍**：~~設觸發於第 k 關，`bonus = payout(k) − payout(k−1)`
   （k 為本局第一關時前值取 0）。此後
   `current_payout = floor(bet × run_multiplier_at(stage)) + bonus_total`，
   bonus 為固定加項，保留到撤退/通關結算；戰死照樣全失。一局可多次觸發，累加。~~
   **【2026-07-11 D-022 修訂，取代上文】本局收益翻倍**：觸發時
   `huye_payout_factor ×= payout_factor`（json，預設 2.0），乘進
   current/next multiplier（顯示與計算同源），
   `current_payout = floor(bet × run_multiplier × factor)` 延續到結算；
   多次觸發疊乘；戰死照樣全失。`reward_mode = "run_payout_x2"`。
4. **收益同源原則（更新版）**：`_update_payout()`（`game_state_machine.gd:384-392`）
   仍是唯一計算點；所有預測值（`next_stage_payout`、決策畫面「過關可得」、
   結算 FOMO 行）一律含 bonus、走同一計算路徑，禁止 UI 各自加。
   倍率欄照舊顯示倍率盤數值（不把 bonus 折進倍率）；收益欄顯示含 bonus 總額。
   觸發後若想在 HUD 收益旁加個小虎爺標記提示「有加持」，手法自定、非必要。
5. **demo 強制觸發開關**：`random_events.huye.force_trigger`（bool，初值 false），
   true 時每關必觸發。純 debug 欄位，展示/錄影用。
6. `random_events.huye.enabled`（bool，初值 true）：false 時整個事件不存在、
   行為與現況完全相同（回退路徑，仿卡 21 慣例）。

## 二、演出分鏡（節奏你調，順序與意圖不可變）

前提：本關已骰中虎爺。玩家連擊演出照常播完（不劇透）。

1. **假裝要輸**：走敗局的怪物反擊開場——`play_monster_counter()`
   （`battle_presenter.gd:148-150` → `monster_actor.play_counter()`
   `monster_actor.gd:83-91` 的衝刺 tween）。
2. **超慢動作**：怪物衝刺至「快碰到主角」時驟降到極慢（建議正常速播到 ~60-70%
   路程後急剎）。**不要用 `Engine.time_scale`**（全域生效，會連 timer、BGM 節奏
   一起拖慢）；放慢該段 tween 本身（拆兩段 tween、或 `tween.set_speed_scale()`）。
   可配暗角/變暗提升張力（手法自定）。
3. **虎爺壓下**：怪物正上方（取 `battle_presenter.monster_canvas_position()`
   `battle_presenter.gd:109-122`）虎爺貼紙從螢幕外快速砸下，命中瞬間打擊感
   複用 `_play_hit_feel()` 慣例（`battle_presenter.gd:235-239`：HitFlash＋震動＋punch）。
4. **怪物卡通式飛出**：被壓中的怪物往**左上角**飛出螢幕——位移＋旋轉＋縮小
   同時 tween，出畫後收尾。**注意：monster node 跨關重用，演出後必須重置
   position/rotation/scale/visible/modulate，否則下一關怪物會繼承離場狀態**
   （用複製體演出、本體先隱藏，是最穩的做法，自定）。
5. **大字插頁＋虎爺對話框**：仿 `win_banner.gd` 的 CanvasLayer 插頁慣例
   （dimmer＋BACK 彈入＋點擊任意處消失＋auto_dismiss 保底）：
   大標題（`huye_banner_title`）＋「x2 BONUS」式視覺＋本次 bonus 金額；
   虎爺立繪旁一個對話框（程式畫奶油圓角框＋尾巴或用選配素材），
   台詞 `huye_dialog`。文案全走 `ui_text.json`，人類保留改句權（D-019 §4）。
6. **收尾**：插頁消失 → 爆金幣（卡 19 `CoinBurst`，起點可用怪物飛出點或畫面
   中央，自定）→ 照常進 REWARD_DECISION。整段（慢動作起至可操作）建議 4–6 秒，
   全部時長進 json 可調。

演出期間鎖輸入的慣例照現有 presenter signal 鏈（presenter emit → controller →
state_machine finish_xxx），新增虎爺演出 signal 照同 pattern 接。

## 三、資料驅動欄位（新增，帳面同步 `Docs/06_DATA_SCHEMA.md`）

- `Data/game_balance.json` 新增頂層 `random_events.huye`：
  `enabled` / `trigger_probability` / `force_trigger` / `reward_mode`（本卡固定
  `"stage_increment_x2"`，留欄位給未來事件）。存取器仿 `multiplier_random_config()`
  在 `data_loader.gd` 加一個。
- `Data/animation_timing.json` 新增 `effects.huye_event`：慢動作速率/剎車點、
  虎爺砸下時長、怪物飛出時長與旋轉圈數、插頁 appear/min_show/auto_dismiss 等，
  數字全由此讀。
- `Data/ui_text.json` 新增 key（初稿你寫，博奕語感，人類會自己改句）：
  `huye_banner_title`（如「遇見虎爺！」）、`huye_banner_sub`（如「本關收益翻倍！」）、
  `huye_bonus_label`（帶 `{amount}`）、`huye_dialog`（虎爺台詞，參考風格：
  「喵～有緣貓！虎爺庇佑你！」）。
- `Data/audio.json`：可順手預留 `sfx_huye_appear` 事件 key（缺檔靜音慣例，D-014），
  非必要。

## 四、素材（設計師並行作業——檔名路徑就是合約）

接通模式沿 `title_banner` 先例（`game_controller.gd:151-162`）：程式用
`ResourceLoader.exists` 載入固定路徑（**匯出版禁用 `FileAccess.file_exists`**，
見 VALIDATION_CHECKLIST 通用教訓）＋缺圖 fallback；設計師之後 git push
**同檔名**覆蓋即自動換裝，程式零改動。

| asset_id | 檔名/路徑 | 規格 | fallback |
|---|---|---|---|
| huye | `Assets/final/huye.png` | 虎爺本體單張貼紙，PNG32 透明，建議 700–900px 見方（要壓得住 ~480px 的怪物），姿勢=居高臨下壓下/盤坐雲上皆可，風格同流浪貓街頭 cartoon 家族 | 你先用生成貼紙 skill 產一張暫代放同路徑（D-012 先例；manifest status 標 `generated`），再缺則程式 placeholder（金色圓＋描邊「虎爺」字），不崩 |
| huye_bubble | `Assets/final/ui/huye_bubble.png` | 選配：對話框底圖（**不含文字**，文字程式疊，鐵則 6） | 程式畫奶油圓角框 |
| huye_title | `Assets/final/ui/huye_title.png` | 選配：「遇見虎爺」彩字大標貼紙（**不含金額數字**） | 程式 ribbon 標題（WinBanner 慣例） |

三列登記 `Assets/ART_ASSET_MANIFEST.md`（已由開卡方預登，接入後更新 status）。
若你認定與 `Art/ART_CONTRACT.md` 鎖定條款衝突 → 停下走 `Q-ART-XXX`。
虎爺若未來要序列圖動畫，走 boss 的 TexturePacker 慣例，本卡不做。

## 五、鐵則提醒（其餘手法自定）

1. 數值/文案/時長一律 json，禁寫死（含 5%、x2、所有 tween 秒數）。
2. 不改既有勝負骰與倍率盤的隨機流；`enabled=false` 時行為與現況 bit 級相同。
3. 每張新圖都有缺圖 fallback；H5 匯出版驗一次（ResourceLoader 陷阱）。
4. 版面/演出視覺需實跑目視確認並附截圖（D-006；`tmp/ui_capture` harness 與
   D-021 H5 預覽迴圈皆可用，見卡 23 的驗證方式段）。

## 六、驗收

- `force_trigger=true` 實跑：完整演出鏈（連擊→反擊慢動作→虎爺壓下→怪物左上
  旋轉縮小飛出→插頁+對話框→爆金幣→決策畫面），附關鍵幀截圖（慢動作、壓下、
  飛出、插頁各一）。
- 數值驗證（headless 腳本，仿卡 21 `tmp/test_multiplier.tscn` 慣例）：
  (a) 觸發關收益 = 前關收益 + 2×增額；(b) 後續各關 = floor(bet×倍率)+bonus；
  (c) 決策畫面「過關可得」與結算含 bonus 同源；(d) 戰死歸零；
  (e) `enabled=false` 回歸現況；(f) 機率統計近 5%（±抽樣誤差）。
- 下一關怪物 transform 無殘留（觸發後續戰一關，截圖確認怪物正常站位）。
- 缺圖 fallback 抽驗：改壞 huye.png 路徑 → 事件照常可玩、不崩。
- H5 匯出實跑一次（含 force_trigger 演出）。
- 帳面：manifest status、`Docs/06_DATA_SCHEMA.md` 新欄位、
  `VALIDATION_CHECKLIST.md` 補「里程碑 — 任務 24」、`AGENTS.md` 順序表勾選留給人類目視後。

## 完成後必須回報

依 `AGENTS.md` 格式（附演出關鍵幀截圖＋數值驗證輸出＋新增 json 欄位清單）。
