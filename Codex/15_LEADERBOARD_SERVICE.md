# 任務 15：排行榜服務層（介面 + Mock 實作，Codex 執行）

> **前置**：D-016 已定案。本卡**純 Godot 工作、不碰 Firebase**（Phase 2 見卡 17）。

## 目標
建立 `LeaderboardService` 抽象介面與 `MockLeaderboardService` 實作（資料驅動 NPC 名單），並補齊本局統計，讓卡 16 的四個 UI 接觸點有資料可用。**介面設計成非同步（signal 回傳），Phase 2 換 Firebase 實作時 UI 與 core 零修改。**

## 必讀
`Docs/DECISIONS.md`（D-016，特別是排名指標定義 §5）、`Docs/08` §八、`Scripts/services/score_service.gd`（介面+實作分離的既有慣例）。

## 範圍
1. **`Scripts/services/leaderboard_service.gd`（介面）**，全部非同步風格：
   - `request_top(n: int)` → signal `top_loaded(rows: Array)`；row = `{rank, display_name, best_payout, is_me}`
   - `request_rank_for(payout: int)` → signal `rank_loaded(rank: int, beaten_percent: int)`
     （排名 = 比它高的人數+1；beaten_percent = 比它低的人數/總數，取整）
   - `submit_best(payout: int)`（僅在高於自己既有紀錄時生效）
2. **`Scripts/services/mock_leaderboard_service.gd`**：
   - 讀 `Data/leaderboard_mock.json`（新增）：`entries[] = {display_name, best_payout}` 的 NPC 名單（15–25 筆、分數分布要讓「第 8 名」「超過 72%」這類數字合理）。
   - 玩家本人以 `score_service.get_best_payout()` + 顯示名稱（登入用 Google 名、未登入用 mock profile 名）併入排序。
   - signal 於呼叫後立即 emit（模擬非同步完成）。
3. **本局統計**：結算時需可取得「本局最深 stage」與「死前 `current_payout`」（失敗畫面用）。若既有 snapshot 已含等價欄位就直接用；否則在 controller 層補**演出用統計**，不動狀態機判定邏輯。
4. 接線：`game_controller` 建立服務並於**撤退成功結算時** `submit_best(current_payout)`。

## 不做
- 不做 UI（卡 16）、不碰 Firebase/網路（卡 17）、不動狀態機轉移與數值。
- NPC 名單不寫死在 .gd（AGENTS 鐵則 6：一律讀 JSON）。

## 驗收
- 編輯器實測：`request_top(10)` 回傳含本人的正確排序；改 mock json 的分數→排名跟著變（資料驅動證明）。
- `request_rank_for()` 的排名/百分比與手算一致（附一組對照）。
- `submit_best` 低於既有紀錄不生效。
- 整局流程行為與現狀一致（服務層純附加）。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 15」。

## 完成後必須回報
依 `AGENTS.md` 格式（附給卡 16 的接點清單與 mock json 欄位說明）。
