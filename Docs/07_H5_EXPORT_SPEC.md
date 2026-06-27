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
- 注意：Web 匯出需 **HTTPS + 正確 COOP/COEP 標頭**（SharedArrayBuffer）。部署到自有網域時伺服器需設定：
  - `Cross-Origin-Opener-Policy: same-origin`
  - `Cross-Origin-Embedder-Policy: require-corp`
- 音訊：行動瀏覽器需使用者互動後才能播放（若加音效，於第一次點擊解鎖）。

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
