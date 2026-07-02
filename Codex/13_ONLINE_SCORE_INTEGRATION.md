# 任務 13：線上分數接入（Godot 端，Codex 執行）

> **前置條件（未滿足不得執行）**：D-015 已定案，且**任務 12 已完成並回報**（Firebase 專案可用、web config 已取得）。

## 目標
遊戲 H5 版可用 Google 登入，分數自動同步到 Firestore；未登入/離線時完整退回本機模式。**不改玩法/數值/狀態機。**

## 必讀文件
`AGENTS.md`、`Docs/DECISIONS.md`（D-015）、`Docs/08_ONLINE_SCORE_SPEC.md`、`Docs/07_H5_EXPORT_SPEC.md`（修訂後）、任務 12 的完成回報（web config）、`Scripts/services/local_score_service.gd`（介面基準）。

## 範圍
1. **`Scripts/services/online_score_service.gd`（新增）**：實作與 `LocalScoreService` 相同的 `ScoreService` 介面；透過 `JavaScriptBridge` 呼叫 Firebase JS SDK（登入、寫入/讀取 best_payout 與餘額）。
2. **fallback 契約（最重要）**：非 Web 平台 / 未登入 / SDK 初始化失敗 / 離線 → 一律自動退回 `LocalScoreService`，玩家無感、遊戲不崩；登入成功時以雲端資料為準並合併本機最佳紀錄（取高者）。
3. **export HTML shell**：載入 Firebase JS SDK 與 web config（config 屬公開設計，可入 repo）。
4. **Web export 設定**：關閉 thread support（依 D-015 / Docs/07 修訂），本機驗證整局流暢。
5. **登入入口 UI（最小化）**：標題/下注畫面加一顆登入/登出鈕與登入狀態顯示；**位置遵守 `Docs/04` 座標契約與版面不變量，必須在 Godot 內目視確認**（D-006）；文案入 `ui_text.json`，禁止寫死。

## 不做
- 不做排行榜、好友、他人資料讀取（Future）。
- 不改玩法、數值、狀態機、結算邏輯；core 不得直接認識 Firebase（只透過 ScoreService 介面）。
- 不在 GDScript 寫死 Firebase 專案字串以外的數值/文案。
- 不動音效（任務 11 範圍）。

## 實作要求（關鍵）
1. 所有雲端呼叫**非同步且不阻塞**狀態機；逾時/失敗靜默退回本機並記 warning。
2. 桌面編輯器內（非 Web）遊戲行為與現狀完全一致（OnlineScoreService 直接讓位 Local）。
3. 寫入頻率節制：僅結算時寫雲端，不逐幀/逐擊寫。
4. 遵守分層：bridge 細節封在 service 內，不外漏到 core/ui。

## 驗收方式
- H5（Hosting 或本機 server）：可 Google 登入，結算後 Firestore 出現/更新自己的分數；重整後登入態與雲端分數正確還原。
- 登出/離線/拒絕登入 → 遊戲照常可玩，分數走本機；無 console 錯誤。
- 桌面編輯器跑整局：行為與接入前一致。
- 版面：登入鈕不破壞不變量（Godot 內目視 + 截圖）。
- 對照 `Codex/VALIDATION_CHECKLIST.md`「里程碑 — 任務 13」逐項自驗。

## 完成後必須回報
依 `AGENTS.md` 完成回報格式（附：fallback 各情境的驗證方式、Hosting 實測截圖）。
