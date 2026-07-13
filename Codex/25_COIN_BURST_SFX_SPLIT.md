# 任務 25：金幣噴發音效獨立事件（Codex 執行）

> 依 `Docs/DECISIONS.md` **D-023**（2026-07-13 人類裁示，修訂 D-019 的音效併檔備註）。
> 一句話：金幣噴發從 `monster_death` 音檔拆出，獨立成兩個新 SFX 事件——
> `coin_burst`（怪物死亡噴金幣）與 `huye_coin_burst`（虎爺獎勵噴金幣，盛大版）。
> 音檔素材人類自行蒐集，本卡只接事件與映射，缺檔靜音（D-014 慣例）。

## 一、契約（定案，不可自行變更）

1. **`monster_death` 事件與現行音檔不動**——它從此專職死亡「poof」聲。
2. 新增兩個 SFX 事件，在 CoinBurst 噴發**實際開始**時各響一次：
   - `coin_burst`：怪物死亡噴發，入口 `_play_monster_death_with_coin_burst()`
	 （`game_controller.gd:459`）。
   - `huye_coin_burst`：虎爺獎勵噴發，入口 `_start_huye_coin_burst()`
	 （`game_controller.gd:407`）。
3. **`burst.play()` 回傳 false（缺 config/缺金幣圖、視覺被跳過）時不得響**——
   沒金幣畫面就沒金幣聲。播放手法自定（call site 播、或 CoinBurst 參數化
   event id 皆可），但兩個入口必須分別對映到正確事件。
4. `Data/audio.json > sfx_events` 預登映射（值是檔名字串，物件形式會壞）：
   ```json
   "coin_burst":      "sfx_coin_burst.ogg",
   "huye_coin_burst": "sfx_huye_coin_burst.ogg"
   ```
   檔案目前不存在，載入時 push_warning 略過是預期行為；人類日後把同檔名
   .ogg 放進 `Assets/final/audio/` 即接上，零程式改動。

## 二、鐵則提醒

1. 只動音效播放，不碰 CoinBurst 的視覺/數量/軌跡邏輯。
2. 不動 D-014 既有九事件的任何映射與呼叫。

## 三、驗收

- 放兩個暫代 .ogg（任意短音）實跑：怪物死亡響 `coin_burst`、
  虎爺（`force_trigger=true`）獎勵噴發響 `huye_coin_burst`，兩者不混。
- 移除暫代檔：兩處靜音、遊戲不崩、console 只有載入期 warning。
- 臨時改壞 `animation_timing.effects.coin_burst` 讓 `play()` 回 false：不響。
- 帳面：`Codex/VALIDATION_CHECKLIST.md` 補「里程碑 — 任務 25」；
  `Docs/SFX_PRODUCTION_LIST.md` 追加段已由開卡方寫好，不用動。

## 完成後必須回報

依 `AGENTS.md` 格式（附驗收各項實測結果）。
