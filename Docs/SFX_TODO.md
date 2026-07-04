# SFX TODO — D-014 音效接檔狀態表

> 依 `Docs/DECISIONS.md` D-014：正式接入 BGM + 既有 SFX 事件播放能力。
> `Assets/final/audio/` 是唯一正式音訊入口；`Data/audio.json > sfx_events` 只列已有音檔的事件，未列事件一律靜音略過。

## 已接入音檔
| 類型 | 檔案 | 狀態 |
|---|---|---|
| BGM | `Assets/final/audio/bgm_main.mp3` | 已接檔，設定讀 `Data/audio.json > bgm` |

## SFX 事件 ID
| event_id | 用途 | 目標檔名 | 狀態 |
|---|---|---|---|
| `button_click` | 所有可按按鈕的觸覺式點擊回饋 | `sfx_button_click.ogg` | 待補音檔；未映射，靜音略過 |
| `attack_hit` | 主角每次命中怪物 | `sfx_attack_hit.ogg` | 待補音檔；未映射，靜音略過 |
| `monster_death` | 怪物死亡縮小淡出 | `sfx_monster_death.ogg` | 待補音檔；未映射，靜音略過 |
| `cashout` | 玩家成功撤退並結算收益 | `sfx_cashout.ogg` | 待補音檔；未映射，靜音略過 |
| `defeat` | 玩家戰敗進入結算 | `sfx_defeat.ogg` | 待補音檔；未映射，靜音略過 |
| `clear` | 玩家通關結算 | `sfx_clear.ogg` | 待補音檔；未映射，靜音略過 |
| `advance` | 玩家選擇續戰 | `sfx_advance.ogg` | 待補音檔；未映射，靜音略過 |
| `bet_confirm` | 玩家確認下注 | `sfx_bet_confirm.ogg` | 待補音檔；未映射，靜音略過 |
| `balance_reset` | 餘額不足時重置為起始餘額 | `sfx_balance_reset.ogg` | 待補音檔；未映射，靜音略過 |

## 接入位置
- `Scripts/services/audio_service.gd`：讀 `Data/audio.json`，預載存在的音檔；缺檔 warning + 靜音。
- `Scripts/core/game_controller.gd`：在既有按鈕與狀態事件處呼叫 `play_sfx()`；呼叫不影響狀態機流程。
