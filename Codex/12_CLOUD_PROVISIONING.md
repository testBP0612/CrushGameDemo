# 任務 12：雲端佈建（Firebase 專案，AI 執行）

> **前置條件（未滿足不得執行）**：`Docs/OPEN_QUESTIONS.md` Q-005 已有人類回答，且 `Docs/DECISIONS.md` 已寫入 **D-015**。
> **執行者：Claude（非 Codex）**——本卡為「AI 併用 CLI 與瀏覽器完成雲端佈建」的展示卡。人類全程在旁，**所有帳號憑證/授權由人類親手點擊或輸入，AI 不經手密碼**。

## 目標
從零建立可用的 Firebase 專案：Google 登入可用、Firestore 可依 rules 讀寫分數、Hosting 可部署——並全程留下步驟紀錄與截圖，作為比賽簡報素材。

## 必讀文件
`AGENTS.md`、`Docs/DECISIONS.md`（D-015）、`Docs/08_ONLINE_SCORE_SPEC.md`（Firestore 結構與 rules 依此）、`Docs/07_H5_EXPORT_SPEC.md`。

## 前置（人類）
- Chrome 已登入欲使用的 Google 帳號（建議個人帳號，避免組織政策阻擋）。
- 在 `firebase login` 與 Console 授權彈窗出現時親手確認。

## 範圍（依序執行）
1. **技術驗證（最先做，過不了就停）**：以最小靜態頁（Hosting 或本機）驗證 `signInWithPopup`（Google）在無 COOP/COEP 標頭下可完成登入。此為 (b) 子決策的落地驗證。
2. **CLI 佈建**：`npm install -g firebase-tools` → `firebase login`（人類授權）→ `firebase init`（Firestore + Hosting）。
3. **瀏覽器操作（Console 獨有步驟）**：建立 Firebase 專案、啟用 Authentication 的 Google provider、取得 web config。
4. **`Firebase/` 資料夾進版控**：`firebase.json`、`.firebaserc`、`firestore.rules`（規則內容依 `Docs/08`：僅本人可讀寫 `users/{uid}` 下之分數文件）。
5. **部署驗證**：deploy rules + 部署測試頁至 Hosting，實際完成一次 Google 登入 + 寫入/讀回一筆測試分數。
6. **過程存證**：關鍵步驟截圖 + 指令紀錄，彙整至 `Planning/` 或任務回報（供簡報）。

## 不做
- 不動 Godot 專案任何檔案（那是任務 13）。
- 不啟用 Spark 免費方案以外的計費功能；不綁信用卡。
- 不建排行榜/他人資料讀取的 rules（Future）。
- 不將任何 secret 進版控（Firebase web config 屬公開設計、可進；私鑰/token 一律不可）。

## 驗收方式
- 測試頁可完成 Google 登入彈窗流程（無 COOP/COEP）。
- Firestore rules 生效：登入者可寫/讀自己的分數；未登入或跨 uid 寫入被拒（用 rules 模擬器或實測驗證）。
- `Firebase/` 設定檔已進版控；佈建步驟紀錄與截圖齊備。
- 對照 `Codex/VALIDATION_CHECKLIST.md`「里程碑 — 任務 12」逐項自驗。

## 完成後必須回報
依 `AGENTS.md` 完成回報格式（附：專案 ID、Hosting URL、rules 摘要、驗證截圖清單、供任務 13 使用的 web config 位置）。
