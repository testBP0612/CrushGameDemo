# Scripts/

GDScript 程式碼分層存放區。由 **Codex 依任務卡建立**，本階段僅有骨架說明。
**禁止把所有邏輯集中在單一巨大 script**，請依下列分層落地。

## 分層責任

| 路徑 | 責任 | 代表 class（建議） |
|---|---|---|
| `core/` | 遊戲總控、狀態機、資料載入、事件匯流排 | `GameController`、`GameStateMachine`、`DataLoader`、`EventBus` |
| `battle/` | 戰鬥流程編排、倍率/收益計算、成功率判定 | `BattleDirector`、`PayoutCalculator`、`RiskResolver` |
| `actors/` | 主角與怪物的演出控制（動畫狀態、受擊、死亡） | `HeroActor`、`MonsterActor` |
| `ui/` | UI 控制：下注面板、本局資訊、結算、按鈕狀態 | `BetPanel`、`HudInfo`、`SettlementPanel` |
| `effects/` | 傷害數字、hit flash、撤退/戰敗特效 | `DamageNumber`、`HitFlash` |
| `services/` | 抽象服務層：分數、玩家資料、排行榜（MVP 只做 Local/mock） | `ScoreService`、`LocalScoreService`、`PlayerProfileService`、`LeaderboardService` |

## 規則

- 數值與設定一律從 `Data/*.json` 讀取（單一真實來源），**禁止寫死**倍率/成功率/文案。
- 服務層以介面 + 實作分離，Future 可替換成 `ApiScoreService` / `FirebaseScoreService` / `FirebaseLeaderboardService`。
- 詳細責任見 `Docs/02_SYSTEM_SPEC.md` 與 `Docs/03_STATE_MACHINE.md`。
