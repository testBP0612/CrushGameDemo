# OPEN QUESTIONS — AI 不確定事項清單

> 這是 **AI（Codex / Claude）遇到不明確處的唯一登記簿**。
> 規則：Codex **不得自行猜測核心玩法或擅自決定方向**。遇到不確定，**寫進這裡**，等人類回答，
> 回答定案後再把結論搬到 `DECISIONS.md`，並標記此問題為已解決。

## 使用格式
```md
### Q-XXX：<簡短標題>
- 狀態：OPEN / ANSWERED
- 提出者：Codex / Claude / 人類
- 背景：為什麼會卡住（哪張任務卡、哪個檔案）
- 選項：A / B / C（附簡短利弊）
- AI 建議：<建議哪個>
- 影響範圍：哪些 Codex 任務卡 / Data JSON / 場景 / 素材
- 人類回答：<人類填，定案後寫入 DECISIONS.md 編號>
```

## 美術規格變更專用格式（Art Contract 已 `v1.0 locked` 時必用）
> 任何想改動 `Art/ART_CONTRACT.md` 鎖定內容者（含 AI），**禁止直接改檔**，先在此登記：
```md
### Q-ART-XXX：<想改的合約項目>
- 狀態：OPEN
- 想改什麼：必要素材清單 / 檔名 / 路徑 / 透明背景 / 角色面向 / 背景比例 / 匯入方式 / 預期檔名…
- 原因：
- 影響：哪些 Codex 任務卡（特別是 08）、哪些 manifest 條目、哪些 Data JSON
- 建議新版本號：v1.1
- 人類裁示：<同意升版 / 駁回 / 修改後同意>
```

---

## 現有問題

### Q-001：餘額不足時的處理
- 狀態：ANSWERED → 見 DECISIONS D-007
- 提出者：Claude
- 背景：當 `balance < min_bet`，玩家無法下注，需要復原機制（`02_SYSTEM_SPEC.md` 第四節）。
- 選項：
  - A. 一鍵把餘額重置為 `starting_balance`（最簡單，適合 demo）。
  - B. 給予固定救濟金幣。
  - C. 顯示「遊戲結束」並只能重整。
- AI 建議：A（內部試玩 demo 體驗最順）。
- 影響範圍：`05_SETTLEMENT_AND_LOCAL_SCORE` 任務卡、`ui_text.json`、`LocalScoreService`。
- 人類回答：A

### Q-002：是否需要音效 / 音樂
- 狀態：ANSWERED → 見 DECISIONS D-008
- 提出者：Claude
- 背景：MVP 是否納入基本音效會影響任務卡範圍與 H5 音訊解鎖處理（`07`）。
- AI 建議：MVP 先不做音效，列 Future；若有空檔在 `06_FEEL_AND_EFFECTS` 末段加無關鍵成敗的點擊音。
- 影響範圍：`06_FEEL_AND_EFFECTS`、`07_H5_EXPORT_SPEC`。
- 人類回答：先列出音效空缺就好，把接口預留

### Q-003：缺少正式 UI mockup 圖檔
- 狀態：ANSWERED（採 A：已補上 `Art/references/ui_mockup_battle.png`）
- 提出者：Codex
- 背景：任務 04 指定必讀 `Art/references/ui_mockup_battle.png`，但工作區 `Planning/` 內沒有該檔案；本次只能依 `Docs/04_UI_SPEC.md` 的座標契約與版面不變量實作。
- 選項：
  - A. 補上 `Art/references/ui_mockup_battle.png`，後續 UI 微調以該圖為目標。
  - B. 將 `Docs/04_UI_SPEC.md` 改為不再引用該圖片，只保留座標契約。
- AI 建議：A（保留視覺目標，方便 task 04/後續 review 精準對齊）。
- 影響範圍：`04_H5_VERTICAL_UI`、後續 UI/美術檢查。
- 人類回答：已填入

### Q-ART-001：背景改為分區（新增 background_battle_002/003）
- 狀態：ANSWERED（核准 → 見 DECISIONS D-011，Contract 升 v1.1）
- 想改什麼：必要素材清單（新增 recommended 背景 `background_battle_002`、`background_battle_003`）+ 新增資料驅動的背景選用機制。
- 原因：讓整局有「越闖越深」的分區層次（關 1–3 / 4–6 / 7–10 各一張背景）。
- 影響：`Art/ART_CONTRACT.md`（v1.0→v1.1）、`Assets/ART_ASSET_MANIFEST.md`（+2 背景）、`Data/game_balance.json`（+`background_zones`）、`Docs/06`、`Codex/08`（接入需依 zone 選圖 + fallback）。
- 建議新版本號：v1.1
- 人類裁示：同意升版（規格沿用 001：1080×1920、不透明；缺檔 fallback 不阻塞）。

### Q-ART-002：新增 UI 素材類別（icon 貼紙；面板/按鈕改程式皮膚）
- 狀態：ANSWERED（核准 → 見 DECISIONS D-012，Contract 升 v1.2）
- 想改什麼：manifest 新增「UI 素材」類別（icon 貼紙）；面板/按鈕外框改由程式 StyleBoxFlat 畫，不走美術框貼圖。
- 原因：UI 視覺貼齊貓咪參考圖；粗描邊/份量用程式參數最可控（task 10 Round 2.1）。
- 影響：`Art/ART_CONTRACT.md`（v1.1→v1.2，補 UI 類別與「外框程式畫」原則）、`Assets/ART_ASSET_MANIFEST.md`（+UI icon 區段）、`Scripts/ui/ui_skin.gd`、`Codex/10`。
- 建議新版本號：v1.2
- 人類裁示：同意（icon 用生成貼紙；框/按鈕程式畫；移除未使用的框貼圖）。

### Q-ART-003：sprite sheet 規則修正（加尺寸上限 + 允許 grid）
- 狀態：ANSWERED（核准 → 見 DECISIONS D-013，Contract 升 v1.3）
- 想改什麼：§七 sprite sheet 規則。原文只寫「horizontal sprite sheet」且未設尺寸上限 → 設計師照做出 25 格×768=19200px 單列圖，**超過 H5/手機材質上限(4096~16384)會破圖**。
- 修正：新增**硬上限單邊 ≤ 4096px**；多格數**必須 grid**並於 JSON 標 `columns`/`rows`（少格數仍可單列 horizontal）。
- 原因：原規格缺陷（範例只 6 格沒料到大格數）；設計師無誤、是文件該修。
- 影響：`Art/ART_CONTRACT.md`（v1.2→v1.3 §七）、`Art/ART_SPEC_SHEET.md`、sheet 的 `.json` schema（+columns/rows）、`Codex/08`（切格接入需依 columns/rows）。
- 建議新版本號：v1.3
- 人類裁示：同意。現成的 `hero_idle_sheet`（19200×768）請設計師重出 grid（5×5）。

### Q-004：正式接入音效/音樂（修訂 D-008 的「MVP 不做音效」）
- 狀態：ANSWERED → 見 DECISIONS D-014
- 提出者：人類（指示正式接入）+ Claude（整理選項）
- 背景：D-008 定案 MVP 不做音效、只預留接口。現任務卡 01–10 皆已完成，MVP 限制的前提已消失，人類指示正式接入音效。既有基礎：`AudioService.play_sfx(event_id)` 空殼已在 `game_controller.gd` 接好 9 個事件呼叫點（清單見 `Docs/SFX_TODO.md`）；`Docs/07` 已預告「行動瀏覽器需使用者互動後解鎖音訊」；工作區有候選 BGM `Assets/FishAlleyQuest.mp3`（約 3.7MB，未 commit、未入 final）。音訊素材**不屬 `Art/ART_CONTRACT.md` 鎖定範圍**（合約只管視覺素材），故走一般 Q 而非 Q-ART。
- 待決子項與選項：
  - **(a) 範圍**：
	- A. 只接 BGM（最小改動，先讓遊戲有聲音）。
	- B. BGM + 既有 9 個 SFX 事件的播放能力（**有檔才播、缺檔靜音不崩**；SFX 音檔可之後分批補，架構一次到位）。
	- C. 只接 SFX、不接 BGM。
  - **(b) 素材路徑與命名**：比照 D-004 的 final 入口原則——`Assets/final/audio/` 為唯一正式音訊入口；BGM 命名 `bgm_main.mp3`（`FishAlleyQuest.mp3` 改名移入）；SFX 命名 `sfx_<event_id>.ogg`（或 mp3/wav）。**不需 placeholder 音檔**：缺檔的 fallback 就是靜音（遊戲不可壞）。
  - **(c) 資料驅動**：新增 `Data/audio.json`（event_id→檔名映射、各音量、BGM loop 設定），禁止在腳本寫死檔名/音量（AGENTS 鐵則 6）。
  - **(d) H5 音訊解鎖**：依 `Docs/07`——首次使用者互動（點擊/觸碰）時解鎖並開始播 BGM；解鎖前所有播放呼叫靜默略過。
  - **(e) 靜音/音量 UI**：建議本卡**不做**（避免動版面、觸及 D-006 不變量），列 Future。
- AI 建議：(a) 採 **B**；(b)(c)(d) 依上述；(e) 不做。定案後在 `DECISIONS.md` 新增 **D-014（修訂 D-008）**，同步更新 `AGENTS.md` 的 D-008 摘要行與任務卡順序。
- 影響範圍：新任務卡 `Codex/11_AUDIO_INTEGRATION.md`（已備妥，等本題定案）、`Scripts/services/audio_service.gd`（空殼→實作）、`Data/audio.json`（新增，schema 需同步 `Docs/06`）、`Docs/SFX_TODO.md`（升級為音訊素材對照清單）、`Docs/07_H5_EXPORT_SPEC.md`（音訊解鎖由 Future 轉正式）、`AGENTS.md`、`Codex/VALIDATION_CHECKLIST.md`（+里程碑）。
- 人類回答：照 AI 建議全部採納——(a) B（BGM+SFX 播放能力）、(b)(c)(d) 依建議、(e) 不做靜音 UI。已寫入 DECISIONS.md D-014。

### Q-005：線上身分與分數服務（Google 登入 + 雲端記分）
- 狀態：ANSWERED → 見 DECISIONS D-015
- 提出者：人類（提案）+ Claude（整理選項）
- 背景：人類希望遊戲能 Google 登入並記錄自己的分數，且**展示「AI 併用 CLI 與瀏覽器自行完成雲端佈建」**作為比賽亮點。AGENTS 鐵則 2 禁止擅增「後端」，故本案走正式決策。既有接點：task 05 已定「核心只依賴 `ScoreService` 介面」，`LocalScoreService` 可無縫並存。環境現況：使用者機器已有 Node v22 + npm，Firebase CLI 未裝（由 AI 安裝，屬展示內容）。
- 待決子項與選項：
  - **(a) 選型**：
	- A. **Firebase（Auth + Firestore + Hosting，BaaS）**：零自建伺服器、免費 Spark 方案即可、安全靠 Security Rules；定名「線上身分與分數服務（BaaS）」，非鐵則 2 意義的自建後端。
	- B. 自建後端（Node/Go + DB）：完全掌控，但引入維運/主機成本，違反輕量原則。
	- C. 不做，維持純本機。
  - **(b) H5 執行緒取捨**：cross-origin isolation（COOP/COEP，SharedArrayBuffer 需要）**會擋 Google OAuth popup**。方案：Web export **關閉 thread support**（本遊戲輕量、單執行緒足夠）→ 不再需要 COOP/COEP 標頭，`Docs/07` §二§三需修訂。**此點需最先技術驗證**（任務卡 12 的首項驗收）。
  - **(c) fallback 契約**：未登入/離線/初始化失敗 → 自動退回 `LocalScoreService`，遊戲功能完整不崩（同 D-004/D-014 的缺什麼都不壞原則）。
  - **(d) 範圍**：MVP 只做「登入 + 記錄/讀取**自己的**分數」；排行榜（讀他人資料的 rules 複雜度）列 Future。
  - **(e) 佈建方式**：CLI 能做的用 CLI（init/rules/deploy），Console 獨有步驟（建專案、啟用 Google provider）用 AI 瀏覽器操作；**憑證/密碼一律由人類親手輸入，AI 不經手**；全程截圖存證供簡報。
  - **(f) 部署**：遊戲 `export/web/` 部署至 Firebase Hosting，與 auth 同源，登入設定最簡。
- AI 建議：(a) 採 **A**；(b)–(f) 依上述。定案後寫 `DECISIONS.md` **D-015**、新增 `Docs/08_ONLINE_SCORE_SPEC.md`（auth 流程、Firestore 結構、rules、fallback 契約）、更新 `AGENTS.md`（鐵則 2 補充 BaaS 定位 + 任務卡順序）與 `Docs/07`。
- 影響範圍：新任務卡 `Codex/12_CLOUD_PROVISIONING.md`（執行者：Claude，CLI+瀏覽器）、`Codex/13_ONLINE_SCORE_INTEGRATION.md`（執行者：Codex，Godot 接入）、`Firebase/` 新資料夾（firebase.json/.firebaserc/firestore.rules 進版控）、`Scripts/services/`（新增 online_score_service.gd）、export HTML shell、`Docs/07`、`AGENTS.md`、`Codex/VALIDATION_CHECKLIST.md`。
- 人類回答：照 AI 建議全部採納——(a) A（Firebase BaaS）、(b)–(f) 依建議。已寫入 DECISIONS.md D-015。
