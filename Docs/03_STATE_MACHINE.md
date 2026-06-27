# 03 — 狀態機（State Machine）

> Codex 必讀 #3。這是遊戲流程的權威定義。Codex 實作的狀態機**必須**對應本檔的狀態與轉移。

## 一、狀態總覽
```
BOOT
 └─> TITLE
      └─(點擊開始)─> BETTING
                       └─(確認下注)─> CHALLENGE_START
                                        └─> BATTLE_ATTACK
                                             └─(連擊播完，判定)
                                                 ├─ 勝 ─> MONSTER_HURT ─> MONSTER_DEATH ─> REWARD_DECISION
                                                 └─ 敗 ─> MONSTER_COUNTER ─> PLAYER_HURT ─> DEFEAT_SETTLE
REWARD_DECISION
 ├─(撤退領取)─> CASH_OUT_SETTLE ─> BETTING
 ├─(挑戰下一隻 & 未達 max)─> ADVANCE_WALK ─> TRANSITION ─> CHALLENGE_START
 └─(已達 max_stage)─> CLEAR_SETTLE ─> BETTING
DEFEAT_SETTLE ─> BETTING
CASH_OUT_SETTLE / CLEAR_SETTLE ─> BETTING
```

## 二、各狀態定義
| 狀態 | 進入條件 | 可互動按鈕 | 播放動畫 | 資料更新時機 | 離開條件 | 驗收點 |
|---|---|---|---|---|---|---|
| `BOOT` | 遊戲啟動 | 無 | 無 | 載入 `Data/*.json`、初始化 services | 載入完成 | 無錯誤進 TITLE |
| `TITLE` | BOOT 完成 | 開始 | Logo / hero idle | 顯示 best_record | 點擊開始 | 顯示標題與最佳紀錄 |
| `BETTING` | 進入下注 | −/＋/開始挑戰 | hero idle、monster(stage1) idle | 重置 stage=0、顯示 balance | 確認下注且 `balance>=bet` | 下注上下限/步進正確 |
| `CHALLENGE_START` | 確認下注 | 無 | hero idle→備戰 | `balance -= bet`、決定本關 success_rate | 進入攻擊 | 餘額正確扣除 |
| `BATTLE_ATTACK` | CHALLENGE_START | 無（鎖定） | hero attack ×N（3~5） | 播放傷害數字 | 連擊播完 | 連擊次數取自 monsters.json |
| `MONSTER_HURT` | 判定為勝 | 無 | monster hurt | — | 演出結束 | 僅勝利分支進入 |
| `MONSTER_DEATH` | MONSTER_HURT | 無 | monster death | `stage += 1`、更新 multiplier/current_payout | 演出結束 | 倍率/收益正確提升 |
| `REWARD_DECISION` | MONSTER_DEATH | 撤退領取 / 挑戰下一隻 | hero idle（勝利姿態） | 顯示新 payout、按鈕文案帶入金額 | 玩家點選 or 已達 max | 兩按鈕可互動且正確 |
| `ADVANCE_WALK` | 選擇繼續且未達 max | 無 | hero walk | — | 行走演出結束 | 僅未達 max 進入 |
| `TRANSITION` | ADVANCE_WALK | 無 | 場景轉場 | 載入下一隻怪物資料 | 轉場結束 | 下一隻怪物正確 |
| `CASH_OUT_SETTLE` | 選擇撤退 | 確認/再來一局 | 撤退特效 | `balance += current_payout`、`submit_payout` | 玩家確認 | 餘額/紀錄正確 |
| `MONSTER_COUNTER` | 判定為敗 | 無 | monster 反擊 | — | 演出結束 | 僅失敗分支 |
| `PLAYER_HURT` | MONSTER_COUNTER | 無 | hero hurt / defeat | — | 演出結束 | — |
| `DEFEAT_SETTLE` | PLAYER_HURT | 確認/再來一局 | 戰敗特效 | `current_payout=0`（bet 已扣） | 玩家確認 | 損失正確、無負餘額 |
| `CLEAR_SETTLE` | 已達 max_stage | 確認/再來一局 | 通關特效 | `balance += current_payout`、`submit_payout` | 玩家確認 | 通關強制結算 |

## 三、UI 狀態對應
- **下注面板**：僅 `BETTING` 顯示且可互動。
- **本局資訊列（HUD）**：`CHALLENGE_START`~`REWARD_DECISION` 顯示 stage / multiplier / current_payout。
- **決策雙按鈕**：僅 `REWARD_DECISION` 顯示且可互動（達 max 時自動走 CLEAR_SETTLE，不顯示「挑戰下一隻」）。
- **結算面板**：`CASH_OUT_SETTLE` / `DEFEAT_SETTLE` / `CLEAR_SETTLE` 顯示。
- **戰鬥訊息**：`BATTLE_ATTACK`~`MONSTER_DEATH` / 失敗分支顯示對應 `battle_msg_*`。

## 四、事件流（建議用 EventBus 解耦）
建議信號：`data_loaded`、`bet_confirmed(bet)`、`attack_finished`、`result_resolved(is_win)`、
`stage_advanced(stage, multiplier, payout)`、`cashout_requested`、`advance_requested`、`settled(result)`。
UI 訂閱事件更新畫面，不直接讀狀態機內部變數。

## 五、時間節奏
所有演出時長取自 `Data/battle_sequences.json` 與 `Data/animation_timing.json`，**禁止寫死**。
