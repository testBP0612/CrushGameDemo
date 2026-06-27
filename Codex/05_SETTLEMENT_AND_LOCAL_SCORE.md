# 任務 05：結算與本機分數服務

## 目標
完成撤退/戰敗/通關三種結算面板與流程，並實作 `LocalScoreService` 與 mock `PlayerProfileService`，餘額與最佳紀錄存於 local。

## 必讀文件
`Docs/02_SYSTEM_SPEC.md`（結算規則、服務抽象層）、`Docs/03_STATE_MACHINE.md`（SETTLE 狀態）、`Docs/06_DATA_SCHEMA.md`。

## 範圍
- `Scripts/services/score_service.gd`（介面）+ `local_score_service.gd`（存 `user://save.json`）。
- `Scripts/services/player_profile_service.gd`（回傳 mock profile）。
- `SettlementPanel` 三種狀態：撤退成功 / 挑戰失敗 / 完美通關（文案 key 見 ui_text）。
- 結算後更新餘額、`submit_payout` 更新最佳紀錄、回到 BETTING。
- 處理 `OPEN_QUESTIONS Q-001`（餘額不足）：依人類定案實作；若仍未定案，暫用「重置為 starting_balance」並標註。

## 不做
- 不接後端 / 登入 / 排行榜（Future，只保留介面）。
- 不做反作弊。

## 實作要求
1. 遊戲核心只依賴 `ScoreService` **介面**，實作可替換（注入點集中一處）。
2. 存檔讀寫要容錯：檔案不存在時用 `starting_balance` 初始化。
3. 最佳紀錄（`best_payout`）跨場次保留，TITLE 顯示。
4. 結算文案以 key 取用，金額以變數代入。

## 驗收方式
- 撤退 → 餘額正確增加、若破紀錄則 best 更新。
- 戰敗 → 餘額正確（僅失去 bet），best 不變。
- 通關（清空 max_stage）→ 強制結算並加收益。
- 關閉重開遊戲，餘額與 best 仍保留。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 格式。
