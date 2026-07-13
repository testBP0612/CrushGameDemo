# 任務 26：虎爺事件 BGM 切換＋huye_appear 命名統一（Codex 執行）

> 依 `Docs/DECISIONS.md` **D-024**（2026-07-13 人類裁示）。
> 一句話：虎爺降臨時主 BGM 淡出、切入虎爺專屬循環 BGM，事件收尾淡回主 BGM
> 並**接續原播放進度**——博奕遊戲 FREE GAME 的標準音樂語言。
> 順手把事件 ID `sfx_huye_appear` 統一為 `huye_appear`。
> 音檔（`bgm_huye.ogg`）人類自行蒐集，缺檔不切換、主 BGM 照播（D-004 不崩）。

## 一、機制契約（定案，不可自行變更）

1. `audio_service.gd` 新增事件 BGM 能力（介面名建議，可微調）：
   - `play_event_bgm(event_id: String)`：讀 `audio.json > event_bgm[event_id]`。
	 主 BGM 以 `fade_out` 秒淡出後**暫停並記錄播放位置**；事件 BGM 由專屬的
	 第二個 `AudioStreamPlayer` 播放，音量 `volume_db`，`loop` 依欄位
	 （虎爺必 loop——banner 等玩家點擊、事件時長不定）。
   - `stop_event_bgm()`：事件 BGM 淡出停止；主 BGM **從記錄位置續播**、
	 以 `fade_in` 秒淡回 `bgm.volume_db`。
2. **健壯性邊界**：
   - `event_bgm` 無該 id、或音檔不存在 → `play_event_bgm` 完全 no-op
	 （主 BGM 不中斷，演出照常）。
   - 未啟動狀態下呼叫 `stop_event_bgm` → no-op；重複 `play` 同 id 防重入。
   - `stop_all()` 一併停事件 player 並清記錄狀態。
   - Web audio unlock（`_audio_unlocked=false`）時語意與現行 BGM 一致：不播。
3. **呼叫點**（controller 層）：
   - 切入：進 `HUYE_RESCUE` 演出時（`_play_presentation_for_state` 的
	 `"HUYE_RESCUE"` 分支，`game_controller.gd:443`）`play_event_bgm("huye")`。
	 虎爺 BGM 覆蓋整段：慢動作 → 壓飛 → banner → 獎勵金幣。
   - 切回：獎勵金幣噴發完成的 callback（`_start_huye_coin_burst` 的
	 `completed`，`game_controller.gd:411-414`）先 `stop_event_bgm()` 再
	 `finish_huye_rescue()`。
4. **命名統一**：`game_controller.gd:388` 的 `"sfx_huye_appear"` 改
   `"huye_appear"`；`audio.json > sfx_events` 預登
   `"huye_appear": "sfx_huye_appear.ogg"`（事件裸名、檔名維持 `sfx_` 前綴，
   與九事件慣例一致；音檔尚缺，缺檔靜音）。

## 二、資料驅動欄位（帳面同步 `Docs/06_DATA_SCHEMA.md`）

`Data/audio.json` 新增頂層 `event_bgm`（初值如下，秒數/音量全由此讀，禁寫死）：

```json
"event_bgm": {
  "huye": {
	"file": "bgm_huye.ogg",
	"loop": true,
	"volume_db": -6.0,
	"fade_out": 0.4,
	"fade_in": 0.6
  }
}
```

## 三、鐵則提醒

1. 不動主 BGM 既有載入/unlock/loop 邏輯的行為（無事件時 bit 級相同）。
2. 淡入淡出秒數、音量一律 json，禁寫死。
3. 不碰虎爺演出視覺與狀態機時序——只加音訊層。

## 四、驗收

- 放暫代 loop 音檔（任意可循環 ogg）實跑 `force_trigger=true`：
  主 BGM 淡出 → 事件 BGM 循環播滿整段（含 banner 停留）→ 金幣飛完
  淡回主 BGM，**人耳確認接續原進度**（非從頭）。
- 刪掉 `bgm_huye.ogg`：主 BGM 全程不中斷、演出照常、不崩。
- 連續觸發兩關（force_trigger 連打）：切換兩輪無狀態殘留。
- 虎爺局後撤退進結算、再開下一局：BGM 狀態正常、`stop_all` 無殘留。
- `huye_appear` 改名後放暫代音檔：虎爺落地衝擊有聲。
- H5 匯出版實測一次（audio unlock 路徑，`ResourceLoader` 陷阱照舊注意）。
- 帳面：`Docs/06_DATA_SCHEMA.md` 補 `event_bgm`、
  `Codex/VALIDATION_CHECKLIST.md` 補「里程碑 — 任務 26」。

## 完成後必須回報

依 `AGENTS.md` 格式（附各驗收項實測結果；BGM 切換建議附一段錄影/錄音）。
