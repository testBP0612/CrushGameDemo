# 02 — 系統規格（System Spec）

> Codex 必讀 #2。本檔定義數值計算、判定規則與服務抽象層。

## 一、術語
- `bet`：本局下注金額（金幣）。
- `stage`：目前進度，等於**已擊敗的怪物數**（從 0 起算，擊敗第一隻後為 1）。
- `multiplier`：`stage` 對應的倍率（查 `multiplier_curve`）。
- `current_payout`：目前可撤退領取的收益。
- `balance`：玩家金幣餘額。

## 二、收益計算
```
current_payout = floor(bet * multiplier_at_stage(stage))
```
- `stage = 0`（尚未擊敗任何怪物）時 `multiplier = 1.0`，`current_payout = bet`。
- `multiplier_at_stage` 從 `Data/game_balance.json > multiplier_curve` 查表。
- `rounding` 依 `payout.rounding`（預設 `floor`）。

## 三、成功率與判定
- 每一關挑戰，於連擊演出播放完畢後判定成敗。
- 成功率 = `Data/game_balance.json > success_rate_curve` 中對應「即將挑戰的關卡」之 `success_rate`。
- 判定：`is_win = randf() < success_rate`。
- 判定使用 Godot `randf()`；MVP **不做**伺服器驗證 / 反作弊（Future Phase）。

## 四、結算規則
| 結果 | 餘額變化 | 說明 |
|---|---|---|
| 開始挑戰（下注） | `balance -= bet` | 進入戰鬥時即扣除下注。 |
| 撤退領取 | `balance += current_payout` | 帶走目前收益，回到下注狀態。 |
| 挑戰失敗 | （不返還） | 已扣的 `bet` 不返還，`current_payout` 歸零。`loss_mode = lose_current_payout_and_bet`。 |
| 完美通關（清空 max_stage） | `balance += current_payout` | 強制結算，等同撤退。 |

> 邊界：餘額不足 `min_bet` 時的處理 → 見 `OPEN_QUESTIONS.md`（暫定：可一鍵重置為 `starting_balance`）。

## 五、服務抽象層（MVP 只實作 Local / mock）
位於 `Scripts/services/`。以「介面 + 實作」分離，預留 Future 替換。

### ScoreService（介面）
```
get_balance() -> int
set_balance(value: int) -> void
get_best_payout() -> int
submit_payout(payout: int) -> void   # 更新最佳紀錄
```
- MVP 實作：`LocalScoreService`，以 Godot `FileAccess` 存於 `user://save.json`。

### PlayerProfileService（介面）
```
get_profile() -> Dictionary   # { "player_id", "display_name", "avatar" }
```
- MVP 實作：回傳 **mock** profile（不接登入）。

### Future（只預留介面，不實作）
- `ApiScoreService` / `FirebaseScoreService`：替換 `ScoreService`。
- Google Login → 替換 `PlayerProfileService`。
- 排行榜、反作弊、伺服器驗證。

> 設計要點：遊戲核心只依賴**介面**，不直接依賴實作。切換實作只改注入點（建議在 `GameController` 或一個簡單的 service locator 中決定要 new 哪個實作）。

## 六、明確不做（MVP）
大型會員系統、完整經濟系統、商城、裝備養成、抽卡、大型後端、多人同步、複雜反作弊、
真動作戰鬥、複雜怪物 AI、關卡編輯器。
