# 08 — 線上身分與分數規格（Online Score Spec）

> Codex 必讀 #8（任務 12/13 適用）。依據 `DECISIONS.md` D-015。
> 定位：**BaaS（Firebase），零自建伺服器**。MVP 只做「Google 登入 + 自己的分數」。

## 一、範圍

- 做：Google 登入/登出、雲端保存與還原自己的 `best_payout` 與 `balance`。
- 不做（Future）：排行榜、好友、讀取他人資料、帳號合併、匿名登入升級。

## 二、Auth 流程

- 僅 Web 平台啟用（桌面編輯器一律本機模式）。
- `signInWithPopup`（Google provider）。前提：Web export 已關閉 thread support、
  部署端不送 COOP/COEP 標頭（D-015 §2，`Docs/07` 修訂）。
- 登入是**可選的**：未登入時遊戲功能完整（fallback 契約見第五節）。

## 三、Firestore 資料結構

```
users/{uid}
  best_payout: int      # 歷史最佳單局收益
  balance: int          # 目前餘額
  display_name: string  # 取自 Google profile，僅顯示用
  updated_at: timestamp # server timestamp
```
- 寫入時機：**僅結算時**（撤退/戰敗/通關）與登入後首次同步。不逐擊寫入。

## 四、Security Rules（`Firebase/firestore.rules`）

原則：**只有本人能讀寫自己的文件，其他一律拒絕。**
```
match /users/{uid} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```
（欄位型別驗證可加強於 Future；MVP 以 uid 隔離為底線。）

## 五、fallback 契約（最重要，違反即 bug）

| 情境 | 行為 |
|---|---|
| 非 Web 平台 | 直接用 `LocalScoreService`，Online 服務不初始化 |
| 未登入 / 拒絕登入 | 本機模式，遊戲完整可玩 |
| SDK 初始化失敗 / 離線 / 逾時 | warning + 靜默退回本機，不阻塞狀態機 |
| 登入成功 | `best_payout` 取本機與雲端較高者；`balance` 以雲端為準，雲端無資料則以本機值初始化雲端 |

合併時機釐清（2026-07-04，任務 13 實作時定）：
- `best_payout` 單調遞增，**隨時可套用**。
- `balance` **只能在局外（BETTING）套用**——登入回報可能在局中非同步抵達，
  局中先暫存（pending），回到 BETTING 才套用並回寫雲端，避免覆寫進行中的一局。
- **雲端載入失敗 ≠ 雲端無資料**：失敗時本次不合併、不回寫，等下次機會；
  只有確認「文件不存在」才以本機值初始化雲端。

- core 只依賴 `ScoreService` 介面（task 05 既有），不得 import/認識 Firebase。
- 所有雲端呼叫非同步、不阻塞、可容錯——任何網路錯誤都不可讓遊戲壞掉。

## 六、佈建產物（任務 12 之後進版控）

- `Firebase/firebase.json`、`Firebase/.firebaserc`、`Firebase/firestore.rules`。
- Firebase web config（apiKey 等）屬**公開設計**，可入 repo（放 export shell 或
  `Firebase/web_config.js`）；私鑰/service account/token **一律不可**入 repo。

## 七、排行榜（D-016 新增）

- 定位：**輕量非同步競爭回饋層**，單局流程不變。指標單一：`best_payout`。
  排名 = 比你高的人數+1；beaten% = 比你低的人數/總數。
- 介面 `LeaderboardService`（signal 非同步）：`request_top(n)`／`request_rank_for(payout)`／
  `submit_best(payout)`。**Phase 1 = MockLeaderboardService**（NPC 名單
  `Data/leaderboard_mock.json`，明示為模擬資料）；**Phase 2 = Firebase 實作**
  （`leaderboard/{uid}`：`display_name`/`best_payout`/`updated_at`；登入可讀、僅本人可寫、
  int + 單調遞增 + ≤1e9；不暴露 `users/` 私人欄位）。
- UI 四接觸點與明確不做清單見 D-016 與 `Codex/16`。

## 八、驗收對照

任務 12 見 `Codex/VALIDATION_CHECKLIST.md`「里程碑 — 任務 12」；任務 13 見「里程碑 — 任務 13」；排行榜見「里程碑 — 任務 15／16／17」。
