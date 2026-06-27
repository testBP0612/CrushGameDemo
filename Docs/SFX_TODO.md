# SFX TODO — D-008 預留音效空缺清單

> 依 `Docs/DECISIONS.md` D-008：MVP 不實作音效播放、不載入音檔，只預留 `AudioService.play_sfx(event_id)` 接口。

## Future 事件 ID
- `button_click`：所有可按按鈕的觸覺式點擊回饋。
- `attack_hit`：主角每次命中怪物。
- `monster_death`：怪物死亡縮小淡出。
- `cashout`：玩家成功撤退並結算收益。
- `defeat`：玩家戰敗進入結算。
- `clear`：玩家通關結算。
- `advance`：玩家選擇續戰。
- `bet_confirm`：玩家確認下注。
- `balance_reset`：餘額不足時重置為起始餘額。

## 接入位置
- `Scripts/services/audio_service.gd`：空殼服務，現階段所有方法皆 no-op。
- `Scripts/core/game_controller.gd`：在既有按鈕與狀態事件處呼叫 `play_sfx()`；呼叫不影響狀態機流程。

