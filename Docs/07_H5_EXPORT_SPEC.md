# 07 — H5 / Web Export 規格

> Codex 必讀 #7。最終要輸出為 H5 部署到自有網域供公司內部試玩。

## 一、目標
- 單機 H5，瀏覽器（桌機 + 行動）可開即玩。
- 9:16 直式，行動瀏覽器體驗優先。

## 二、Godot 專案設定（Codex 在 01 任務卡設定）
- 渲染：保持 `gl_compatibility`（本專案 `project.godot` 已是；Web 相容性最佳）。
- 視窗：`viewport_width=1080`、`viewport_height=1920`。
- 伸縮：`stretch/mode=canvas_items`、`stretch/aspect=keep`（直式置中，兩側留邊）。

## 三、Web Export 設定
- 匯出範本：Godot 4.6 Web（HTML5）。
- Export preset 名稱建議：`Web`。
- 輸出路徑：`export/web/`（已在 `.gitignore` 忽略，不提交輸出物）。
- **Thread support：關閉**（D-015 修訂）。關閉後不需要 SharedArrayBuffer，
  也就**不再需要 COOP/COEP 標頭**——這是為了讓 Google OAuth popup 可用
  （cross-origin isolation 會擋 OAuth popup）。本遊戲輕量，單執行緒足夠。
  此取捨由任務 12 首項技術驗證確認；驗證不過回 D-015 重議。
  - （歷史紀錄：原規格要求 `Cross-Origin-Opener-Policy: same-origin` +
    `Cross-Origin-Embedder-Policy: require-corp`，D-015 後不再適用。）
- 部署：Firebase Hosting（D-015；與 auth 同源，設定見 `Docs/08`）。
- 音訊（D-014 正式接入）：行動瀏覽器需使用者互動後才能播放——**首次使用者互動（點擊/觸碰）時解鎖音訊並開始 BGM**；解鎖前所有播放呼叫靜默略過、不得報 console 錯誤。

## 四、行動瀏覽器注意
- 觸控即點擊；按鈕熱區夠大（直式下方操作區）。
- 避免依賴鍵盤 / 滑鼠 hover。
- 畫面縮放交給 `stretch` 設定，UI 用錨點（anchors）適應安全區。

## 五、驗收（H5 階段，見 VALIDATION_CHECKLIST）
1. `export/web/` 可在本機簡易 HTTP server 開啟並完整跑完一局閉環。
2. 直式比例正確、UI 不溢出、按鈕可點。
3. 重新整理後 local 餘額/最佳紀錄仍保留（`LocalScoreService`）。

## 六、Future（不在 MVP）
CDN 部署自動化、PWA、載入畫面美化、多語系切換、後端連線。
