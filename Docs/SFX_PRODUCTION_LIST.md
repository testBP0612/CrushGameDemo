# SFX 製作清單（給音效產出者：人或 AI 皆可）

> **✅ 完成（2026-07-12，commit b680c88）**：9 個事件音檔全數交付
> `Assets/final/audio/sfx_*.ogg` 並接上 `Data/audio.json > sfx_events`，
> 遊戲不再靜音。本檔轉為規格存檔；日後**換音檔**直接覆蓋同檔名 .ogg 即可。
> 音量微調：整體 `sfx_volume_db`、BGM `bgm.volume_db`（人耳確認仍待人類）。
>
> 遊戲風格：可愛貼紙風、貓咪主角 vs 怪物、手機 H5 休閒。音效要**短、Q 彈、卡通**，
> 不要寫實血腥。狀態對照表見 `Docs/SFX_TODO.md`；本檔只管「要做什麼聲音」。
> 事件 ID 已鎖定（D-014），**只能做這 9 個，不得擅增**。
> （例外備註：卡 24 虎爺事件程式呼叫了第 10 個事件 `sfx_huye_appear`，
> 音檔未製作、audio.json 未列，依 D-014 缺檔靜音；要補聲音時在
> `sfx_events` 加 `"sfx_huye_appear": "sfx_huye_appear.ogg"` 即接上。）

## 接入方式（做完照做即接上，不用改程式）

1. 音檔放入 `Assets/final/audio/`，檔名照下表（格式 `.ogg` 優先，`.mp3`/`.wav` 也可）。
2. 在 `Data/audio.json` 的 `sfx_events` 加一筆映射，**值是檔名字串**
   （audio_service 實作直接把值當檔名，物件形式會壞）：
   ```json
   "sfx_events": {
     "attack_hit": "sfx_attack_hit.ogg"
   }
   ```
   （未列出的事件自動靜音略過，遊戲不會壞。）
3. Godot 編輯器開一次讓它 import，實跑聽一遍確認音量與 `sfx_volume_db: -4.0` 搭配是否合適。

## 清單（依 demo 加分效果排優先）

| 優先 | event_id | 檔名 | 什麼時候響 | 聲音方向 | 長度 |
|---|---|---|---|---|---|
| ★★★ | `attack_hit` | `sfx_attack_hit.ogg` | 主角每次打中怪物（一局會響很多次，最影響手感） | 短促「啵/砰」卡通打擊，帶一點 Q 彈；不要金屬感 | 0.1–0.3s |
| ★★★ | `cashout` | `sfx_cashout.ogg` | 玩家撤退成功、領到收益（爽點時刻） | 金幣灑落＋上揚「叮鈴」，明亮有成就感 | 0.5–1.2s |
| ★★★ | `defeat` | `sfx_defeat.ogg` | 玩家戰敗進結算（風險兌現時刻） | 下墜滑音「咕咚/嗚喔」，滑稽不悲傷（可愛風，不要沉重） | 0.5–1.0s |
| ★★ | `button_click` | `sfx_button_click.ogg` | 所有按鈕點擊 | 輕脆「噗/啪」，軟糖質感；音量要比其他 SFX 低調 | ≤0.15s |
| ★★ | `advance` | `sfx_advance.ogg` | 玩家選擇「續戰下一隻」 | 短上揚「咻」前進感，帶一點緊張 | 0.2–0.5s |
| ★★ | `monster_death` | `sfx_monster_death.ogg` | 怪物死亡縮小淡出 | 卡通「啵嗚～」洩氣/泡泡破掉，滑稽 | 0.3–0.6s |
| ★ | `bet_confirm` | `sfx_bet_confirm.ogg` | 確認下注開局 | 籌碼落桌「叩」＋短確認音 | 0.2–0.4s |
| ★ | `clear` | `sfx_clear.ogg` | 全通關結算（少見但是高光） | 小段勝利號角/鈴鐺，比 cashout 更盛大 | 1.0–1.5s |
| ★ | `balance_reset` | `sfx_balance_reset.ogg` | 餘額不足重置為起始金額 | 中性「叮」提示音，不懲罰感（設計上這不是失敗） | 0.3–0.5s |

## 手工搜尋指南（去素材庫找現成音效用）

推薦來源（都可商用，注意逐檔確認授權標示）：
- **freesound.org**（篩 CC0 授權最省事；CC-BY 要在簡報/README 附署名）
- **pixabay.com/sound-effects**（Pixabay 授權，免署名可商用）
- **kenney.nl/assets**（遊戲音效包 CC0，卡通風常有現成整包，如 "Interface Sounds"、"Impact Sounds"）

各事件搜尋關鍵字（英文為主，素材庫中文結果少）：

| event_id | 搜尋關鍵字 | 挑選要點 |
|---|---|---|
| `attack_hit` | `cartoon punch pop`、`bubble pop hit`、`soft thump boing` | 選最「圓」的，不要拳拳到肉的寫實感；一局響十幾次，聽 10 次不膩再收 |
| `cashout` | `coin drop jingle`、`coins reward`、`cash register ding` | 要有多枚金幣的顆粒感；結尾上揚的優先 |
| `defeat` | `cartoon fail slide whistle`、`sad trombone short`、`descending boing` | 滑稽優先；長度超過 1 秒的剪掉尾巴 |
| `button_click` | `ui click soft`、`bubble click`、`pop click short` | 越不起眼越好，選最「軟」的那個 |
| `advance` | `whoosh short`、`swish transition`、`cartoon dash` | 要有「往前衝」的方向感 |
| `monster_death` | `balloon deflate`、`cartoon poof`、`bubble burst puff` | 洩氣感/泡泡破；此事件與爆金幣同時發生，帶一點金屬碎響也可（金幣聲併入此檔，D-019/卡 19 裁示不另增事件） |
| `bet_confirm` | `poker chip place`、`chip stack click`、`token drop wood` | 籌碼/木桌質感，短促 |
| `clear` | `victory fanfare short`、`level complete jingle cute` | 1 秒出頭的小號角/鈴鐺；比 cashout 更隆重但別拖 |
| `balance_reset` | `notification ding neutral`、`soft chime single` | 中性單音，不能有失敗感 |

**BGM 備註**：現行 `bgm_main.mp3`（FishAlleyQuest）已接好會循環；只有音量還沒人耳確認
（`Data/audio.json > bgm.volume_db: -8.0`，覺得吵改負更多、太小聲往 0 靠）。

## 找齊後的完整接入（複製貼上）

（✅ 已完成——現行 `Data/audio.json` 即為此形式。）檔案全部放進
`Assets/final/audio/`，然後把 `Data/audio.json` 的 `sfx_events` 換成：

```json
"sfx_events": {
  "attack_hit":    "sfx_attack_hit.ogg",
  "cashout":       "sfx_cashout.ogg",
  "defeat":        "sfx_defeat.ogg",
  "button_click":  "sfx_button_click.ogg",
  "advance":       "sfx_advance.ogg",
  "monster_death": "sfx_monster_death.ogg",
  "bet_confirm":   "sfx_bet_confirm.ogg",
  "clear":         "sfx_clear.ogg",
  "balance_reset": "sfx_balance_reset.ogg"
}
```

（下載到的是 .mp3/.wav 也行，副檔名改成一致即可；只找到部分檔案就只列
有的那幾筆，缺的自動靜音不會壞。改完 Godot 編輯器開一次讓它 import，實跑聽一遍。）

## 通用規格

- 響度一致：9 個檔之間主觀音量要接近（整體增益交給 `sfx_volume_db` 統一調）。
- 頭尾不留空白（點擊類尤其不能有起音延遲）。
- 檔案小：單檔 ≤100KB（H5 載入量考量）；`.ogg` 品質 q4–q6 即可。
- 與 BGM（輕快循環曲）疊播要聽得清——中高頻為主，避免和 BGM 打架的低頻轟。

## 最低可行組合

只補 ★★★ 三個（`attack_hit` / `cashout` / `defeat`）就能覆蓋「打擊手感 + 贏的爽 + 輸的張力」
三個核心回饋；比賽 demo 的「完成度感」提升最大的就是這三個。
