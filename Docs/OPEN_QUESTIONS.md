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
  - **(b) 素材路徑與命名**：比照 D-004 的 final 入口原則——`Assets/final/audio/` 為唯一正式音訊入口；BGM 命名 `bgm_main.ogg`（`FishAlleyQuest.mp3` 改名移入）；SFX 命名 `sfx_<event_id>.ogg`（或 mp3/wav）。**不需 placeholder 音檔**：缺檔的 fallback 就是靜音（遊戲不可壞）。
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

### Q-006：排行榜（D-015 Future 項目啟用）
- 狀態：ANSWERED → 見 DECISIONS D-016
- 提出者：人類（提案）+ Claude（整理選項）
- 背景：D-015 把排行榜列 Future；現 D-015 全鏈路已上線驗收（登入/雲端分數/UI，2026-07-04）。人類另已口頭定案多人方向採「第二階：非同步比分競爭」、不做即時連線（2026-07-04 對話），排行榜是該方向第一步。啟用即擴大 AGENTS 鐵則 2 的例外範圍，故開 Q。
- 待決子項與選項：
  - **(a) 資料結構**：獨立集合 `leaderboard/{uid}`（`display_name`/`best_payout`/`updated_at`），與 `users/` 分離——**不暴露 balance 等私人欄位**。結算與登入合併時由 client 順帶同步寫入。
  - **(b) 讀取權限**：
	- A. **需登入才可讀**（內部 demo，建議）。
	- B. 完全公開可讀。
	- 寫入不論何者皆：僅本人文件、rules 驗證型別（int）、**單調遞增**（新值 ≥ 舊值）、sanity 上限（≤ 1e9）。
  - **(c) 防作弊定位（誠實標註）**：client 寫入本質可偽造。內部比賽 demo 採「信任內網玩家 + rules 型別/單調檢查」為底線；伺服器端驗證（Cloud Functions）**需 Blaze 付費方案**，列 Future 不做。
  - **(d) UI 範圍**：標題畫面加「排行榜」按鈕 → 面板顯示 Top 10（名次/暱稱/分數，本人列高亮）；未登入時顯示「登入後查看」提示。不做分頁/好友/歷史曲線。
  - **(e) 每日同種子挑戰**：不在本題——排行榜地基打好後另開 Q-007。
- AI 建議：(a)(d) 依上述；(b) 採 **A**；(c) 接受底線定位。定案後寫 **D-016**，分工沿用：**卡 15（rules+橋接+service）= Claude、卡 16（排行榜 UI）= Codex**。
- 影響範圍：`Firebase/firestore.rules`、`Firebase/web/crush-online.js`、`Scripts/services/online_score_service.gd`、`Docs/08`（+排行榜節）、`AGENTS.md`（鐵則 2 例外範圍、任務順序）、`Codex/15`/`16`（新卡）、`Data/ui_text.json`、manifest（+icon_trophy）。
- 人類回答（2026-07-04，附四張 UI mockup）：採「**輕量 leaderboard-based 非同步競爭**」，
  範圍比原選項更收斂——單局流程完全不動，只加 UI 與資料回饋（四個接觸點：下注畫面入口、
  決策畫面排名提示、撤退成功結算、失敗結算）；**不做**每日挑戰/同種子/模式選擇/即時連線/房間；
  **MVP 先用 Local/MockLeaderboardService 模擬同一資料結構，Firebase 串接列 Phase 2**。
  詳見 D-016。

### Q-ART-004：怪物素材以動畫序列圖交付（命名/路徑與 v1.3 清單不符）
- 狀態：ANSWERED（人類 2026-07-05 裁示照現狀接入 → 見 DECISIONS D-017，Contract 升 v1.4）
- 想改什麼：§二必要素材清單與§三§四命名/路徑。原清單期待靜態 `monster_00N_idle.png`
  置於 `Assets/final/`；美術實際交付**動畫 idle 序列圖** `Assets/final/boss/bossN_idle.png`
  + 同名 `.json`（TexturePacker 格式，N=1..9）。第 10 隻未交付。
- 實測規格：九張皆 3072×2304（4×3 grid、768px 框、12 幀），**符合 v1.3 §七的 ≤4096 硬上限**；
  JSON 含明確 frame 座標與 `meta.animations`，資訊量**優於** v1.3 要求的 `columns`/`rows`。
- 原因：美術升級交付品質（靜態→動畫），且沿用了 hero_idle 的 sheet 規格慣例；屬清單/命名
  的文件面修訂，非素材缺陷。
- 影響：`Art/ART_CONTRACT.md`（v1.3→v1.4：§二怪物條目改序列圖、§四允許 `boss/` 子資料夾、
  §七接受 TexturePacker JSON 為 sheet 中繼資料）、`Assets/ART_ASSET_MANIFEST.md`（怪物區段
  對映 bossN）、`Data/monsters.json`（`art_asset_id` 對映）、新任務卡 `Codex/18`。
- 人類裁示：素材照現狀接入；**第 10 隻暫缺，維持 placeholder**（缺檔 fallback 本就不阻塞）。

### Q-ART-005：背景素材改以 JPG 交付（格式與 §三/§五 不符）
- 狀態：ANSWERED（人類 2026-07-06 目視驗收並指示入庫 → 見 DECISIONS D-018，Contract 升 v1.5）
- 想改什麼：§三檔名規則（`<asset_id>.png`）與 §五圖片格式（PNG）。美術實際交付背景新版
  `background_battle_001/002/003.jpg`（`ART_SPEC_SHEET.md` 原註明「亦可 JPG/WebP→需 Q-ART」，
  即本題）。
- 實測規格：三張皆 **1080×1920 滿版**（符合 §六，且優於舊 png 版 001 的 941×1672）；檔量
  約 300KB/張 vs 舊 png 約 2.2MB/張——**Web 版載入量大幅下降**。
- 原因：背景為不透明全幅底圖，本就不需要 alpha；JPG 是此類素材的合理格式，PNG-only 規則
  是原規格對「角色需透明」的過度概括。
- 程式配套：`battle_presenter.gd` 背景解析改為依副檔名優先序嘗試（`.jpg` → `.jpeg` → `.png`），
  fallback 鏈（zone 背景 → fallback_background_id → 漸層 placeholder）不變。
- 影響：`Art/ART_CONTRACT.md`（v1.4→v1.5：§三/§五 背景允許 JPG）、`Art/ART_SPEC_SHEET.md`、
  `Assets/ART_ASSET_MANIFEST.md`（背景列 file_name）、`Scripts/battle/battle_presenter.gd`。
- 人類裁示：照現狀入庫（jpg 為現行版本，程式優先讀取）；舊 `.png` 三張暫留庫中作備份，
  是否移除以縮小 Web 匯出體積另行決定。

### Q-007：賭場化體驗改版（拿血條、賠率語言、每局隨機倍率盤）
- 狀態：ANSWERED → 見 DECISIONS D-019
- 提出者：人類（提案「遊戲優化討論」三題）+ Claude（整理選項與建議）
- 背景：比賽準備階段的體驗強化。人類提出三個方向：(1) 拿掉血條顯示；(2) 每關倍率隨機
  但漸進式成長；(3) 是否顯示成功率、如何用博奕術語包裝吸引人玩。涉及核心數值來源
  （`game_balance.json > multiplier_curve`）與 UI 資訊呈現，屬方向性決策，開 Q。
- 待決子項與 AI 建議：
  - **(a) 血條**：勝負實為進關瞬間由 success_rate 擲骰決定，血條是暗示「有攻防操作」的
	誤導演出。建議**移除顯示、換成危險度指示**（骷髏/爪印等級圖示，資料驅動分級），
	戰鬥演出內部的血量邏輯保留（動畫節奏依賴它）。
  - **(b) 倍率隨機**：以現有 `multiplier_curve` 為基準，每局開始擲一次「本局盤」——
	每關乘隨機抖動並強制單調遞增；抖動幅度隨關卡放大（低關穩、高關瘋）。
	**success_rate 不連動**（保持固定）：讓各局期望值自然浮動，玩家有「今天盤好」的
	判斷樂趣。揭示規則：**只揭示下一關倍率**（每過一關「開牌」看下一關賠率）。
  - **(c) 成功率顯示**：**不顯示精確 %**（精算師語言勸退玩家）。改為：獎金放大——決策
	畫面主視覺是「過關可得 {金額}」+ 賠率格式「1 賠 N」；風險質化——危險度等級圖示
	（承 (a) 的血條位置）。術語採台式博奕詞：續戰=「過關」（串關滾存）、撤退=「落袋為安」。
	結算加 FOMO 事後揭示：撤退顯示「若再過一關可得…」、戰敗顯示「上一關落袋本可帶走…」。
- 影響範圍：`Data/game_balance.json`（+multiplier_random、+danger_display）、
  `Data/ui_text.json`（新增/修訂文案 key）、`Scripts/core/game_state_machine.gd`（本局盤）、
  `Scripts/battle/battle_presenter.gd`（血條→危險度）、`Scripts/ui/`（決策/結算資訊）、
  新任務卡 `Codex/20`、`Codex/21`、`AGENTS.md`、`Codex/VALIDATION_CHECKLIST.md`。
  副作用（已知會接受）：排行榜 `best_payout` 運氣成分變大。
- 人類回答（2026-07-07，對話中裁示）：三題方向照 AI 建議全部採納。文案**先按博奕遊戲
  術語寫**，但一律走 `ui_text.json` key，**保留人類事後直接改 json 換句子的空間**
  （程式不得依賴字串內容）。已寫入 DECISIONS.md D-019。
