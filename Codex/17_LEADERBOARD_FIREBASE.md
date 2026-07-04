# 任務 17：排行榜 Firebase 實作（Phase 2，Claude 執行）

> **前置（未滿足不得執行）**：任務 15/16 完成且**人類明確啟動 Phase 2**。
> 依 D-016 §4：介面已先行，本卡只是把 Mock 換成真資料來源，UI 與 core 零修改。

## 目標
`FirebaseLeaderboardService` 實作 `LeaderboardService` 介面；Firestore `leaderboard/{uid}` 集合 + rules；橋接擴充。

## 範圍
1. **rules**：`leaderboard/{uid}` — 讀：`request.auth != null`；寫：僅本人 + int 型別 + 單調遞增 + ≤1e9 + `display_name` string。部署並實測四象限（本人寫✓/跨 uid✗/未登入讀✗/登入讀✓）與降分被拒。
2. **`crush-online.js`**：`submitLeaderboard(best, name)`、`fetchLeaderboard(topN)`（orderBy desc）、`fetchRankFor(payout)`（count aggregation）。
3. **`firebase_leaderboard_service.gd`**：同介面 signal 風格；未登入/失敗 → 靜默 fallback 回 Mock 資料或空值（不阻塞）。
4. 服務選擇：Web 且橋接可用 → Firebase 實作；否則 Mock（同 D-015 fallback 精神）。
5. hosted 實測 + 移除/保留 NPC 名單由人類屆時裁示。

## 不做
- Cloud Functions 伺服器驗證（需 Blaze，Future）；好友/分頁/每日挑戰。

## 驗收
對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 17」（rules 四象限、排序正確、fallback 不崩、UI 零修改即換源）。

## 完成後必須回報
依 `AGENTS.md` 格式（附 rules diff、實測輸出）。
