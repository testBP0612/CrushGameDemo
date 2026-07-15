# DECISIONS — 決策紀錄

> 已定案的決策都記在這裡，作為 repo 內的權威依據。
> 格式採 `Planning/02_HUMAN_DECISION_RECORD.md` 範本。決策一旦寫入，AI 與人類都應遵守；
> 要推翻需新增一筆新的 Decision Record（標明取代哪一筆），不要直接刪改舊紀錄。

---

## D-001：Godot 工程留在 repo root
- **問題**：企劃範本把 Godot 工程放在 `GameProject/` 子資料夾，但本 repo 的 `project.godot` 已在 root。
- **選項**：A. 搬進 `GameProject/`；B. 工程留 root，文件夾分區於 root。
- **AI 建議**：B（避免搬動既有 Godot 專案造成 `.import`/uid 重匯入問題）。
- **人類決策**：採 B。
- **原因**：降低重匯入風險、保持簡單。`GameProject/` 為**概念分區**，實體即 repo root 的 `Scenes/Scripts/Data/Assets`。
- **影響**：所有路徑以 repo root 為基準；`README.md` 需說明此對應。

## D-002：Art Contract v1.0 Freeze 流程
- **問題**：如何避免 AI / 任何人擅自改動已確認的美術接入規格，造成 Codex 與美術脫節。
- **決策**：`Art/ART_CONTRACT.md` 一旦標 `v1.0 locked`，其鎖定項目（必要素材清單、檔名/路徑、透明背景、角色面向、背景比例、placeholder/generated/final 流程、Godot 匯入方式、Codex 預期讀取檔名）**不得直接改檔**。
- **變更程序**：`OPEN_QUESTIONS.md`（Q-ART-XXX）→ 本檔新增決策 → 評估影響（任務卡/manifest/Data）→ 人類同意後升 `v1.1`。
- **原因**：固定 Codex 與美術的契約面，允許風格自由但接口穩定。
- **影響**：`README`、`Planning/01`、`Art/ART_CONTRACT.md`、`Codex/00`、`Codex/08`、`Assets/ART_ASSET_MANIFEST.md`。

## D-003：美術風格由美術同事決定，Claude 只定規格
- **問題**：AI 是否該決定美術風格？
- **決策**：明確區分 **Art Contract（不可變，Claude/人類定）** 與 **Art Direction（可變，美術同事定）**。
  Claude 只負責「Godot/Codex 可接入的規格合約」，不替美術同事定死長相/色彩/筆觸/風格。
- **原因**：發揮人類美術判斷，AI 專注結構化落地；同時保證可接入性。
- **影響**：`Art/ART_CONTRACT.md`（合約）、`Art/ART_DIRECTION_NOTES.md`（風格筆記，美術主筆）、`ART_ASSET_MANIFEST.md`。

## D-004：placeholder-first + art-parallel（輕量素材流程）
- **問題**：美術要等遊戲做完才接，還是平行進行？候選稿要不要進 repo？
- **決策**：
  1. Codex 第一階段用 placeholder 完成遊戲本體，不等正式美術、不碰風格。
  2. 美術同事**平行**依 Contract + Manifest 產出。
  3. **候選圖/失敗稿不進 repo**；確認可用後依 manifest 整理直接放 `Assets/final/`。
  4. `Assets/final/` = 唯一正式素材入口；進入即視為符合 Contract、可被 Codex 接入。
  5. `Assets/generated/` 為可選暫存區，非 Codex 依賴；Codex 只讀 `final/` 與 `placeholders/`。
  6. 素材缺失時 Codex 必須 fallback placeholder，不可讓遊戲壞掉。
- **原因**：縮短工期、降低 Git 體積與流程負擔，且不讓美術阻塞遊戲本體。
- **影響**：`Art/ART_CONTRACT.md`、`Planning/06`、`Codex/00`、`Codex/08`、`Assets/*/README.md`、`.gitignore`。

## D-005：DataLoader 改為 autoload 單例 `Data`
- **問題**：任務 01 的 `DataLoader` 是 `game_controller` 的私有成員，但任務 02 起的狀態機/收益/判定都需要同一份資料，放著會各自重複載入或互相耦合。
- **選項**：A. autoload 單例 `Data`；B. game_controller 持有並注入傳遞。
- **AI 建議**：A。
- **人類決策**：採 A，已於任務 02 落實並驗證。
- **原因**：資料是全專案共用的單一真實來源，autoload 最乾淨、避免重複載入。
- **實作**：`data_loader.gd` 改 `extends Node`、`_ready()` 自動 `load_all()`、新增 `is_loaded()`；`project.godot` 註冊 `Data="*res://Scripts/core/data_loader.gd"`。
- **影響**：所有系統透過全域 `Data` 取值，不得各自重新載入。

## D-006：畫面分區改用具體座標契約 + 版面不變量
- **問題**：task 03 的角色被放在畫面正中央，與置中的暫代操作面板重疊。事後分析：角色座標符合 `Docs/04` 的模糊描述（「中段」「中線偏下」），但不符合真實意圖（怪物在上半、UI 在下方分開）。根因是規格用百分比+示意圖+散文，沒有可驗證的座標與不變量，且「角色不可壓到操作區」這條跨任務卡責任沒人收尾。
- **決策**：在 `Docs/04` 新增「二之一 座標契約」（依設計示意圖 `Art/references/ui_mockup_battle.png` 換算的區帶：標題 0–200 / HUD 210–390 / 戰鬥 400–1240 / 操作 1300–1920，含角色基準座標）與「二之二 版面不變量」（角色與操作 UI 不得重疊；操作 UI 必須在 y≥1300；暫代面板亦適用；版面調整必須在 Godot 內目視確認）。並在 `VALIDATION_CHECKLIST` 里程碑 3、4 加入版面驗收項。
- **原因**：把「意圖」編碼成**具體座標 + 硬不變量 + 可驗證的清單項 + 視覺參考圖**，讓後續 AI（與人）能自行對照修復，而非依賴模糊文字。這是「自行修復工作流」的核心手段。
- **影響**：`Docs/04`、`Codex/VALIDATION_CHECKLIST.md`、`Art/references/ui_mockup_battle.png`（已放入）。
- **教訓（重要）**：第一次嘗試修復時，AI 在**沒有 Godot、無法目視**的情況下盲改 `Scenes/Main.tscn` 的像素座標，導致操作面板跑版、按鈕消失。該批盲改已**全部還原**。結論：**場景版面屬視覺產物，必須由能實際執行 Godot 的一方（Codex / 人類）目視驗證後調整**；規劃端（Claude）只負責把版面意圖寫成規格與不變量，不盲改 live 場景。正式 UI 擺位交由 task 04 依示意圖實作。
- **備註**：`Art/ART_CONTRACT.md` Art Contract §六 屬 `v1.0 locked`，本次**未直接改該檔**；其談的是「美術主體在自身畫布內的基準」，與場景擺位（Docs/04）為不同軸，故以收緊 Docs/04 為主。若日後仍造成混淆，再走 `Q-ART-XXX` 修訂。

## D-007：餘額不足時重置為起始餘額（回應 Q-001）
- **問題**：`balance < min_bet` 時玩家無法下注，需復原機制。
- **人類決策**：採 A——一鍵把餘額重置為 `starting_balance`。
- **原因**：內部試玩 demo 體驗最順，不引入救濟/結束畫面等額外系統。
- **影響**：task 05（結算/LocalScore）需在偵測到無法下注時提供重置；`ui_text.json` 可能需一句提示文案。MVP 不做「遊戲結束」畫面。

## D-008：MVP 不做音效，只預留接口與空缺清單（回應 Q-002）
- **問題**：MVP 是否納入音效/音樂。
- **人類決策**：先不實作音效；**列出音效空缺並預留接口**即可。
- **原因**：避免 H5 音訊解鎖與素材成本拖慢 MVP；保留未來擴充點。
- **影響**：task 06（手感）只預留一個音效播放抽象接口（如 `AudioService` 空殼）與「待補音效清單」，不接實際音檔；`07_H5_EXPORT_SPEC` 的音訊解鎖列為 Future。

## D-009：H5 字型改用 OFL 開源字型（取代專有 kaiu.ttf）
- **問題**：task 06 的 H5 export 為解決中文豆腐字，引入了 `kaiu.ttf`（標楷體 / DFKai-SB），屬 Windows 專有字型；commit 到公開 repo 並打包散布有授權風險，且 5.1MB 拖慢載入。
- **人類決策**：
  - **中文**：`jf-openhuninn-2.1.ttf`（粉圓，SIL OFL 1.1）。
  - **英數**：`Baloo2-Medium.ttf`（SIL OFL 1.1）。
  - 移除 `kaiu.ttf`，不得 commit 進 repo。
- **原因**：兩者皆 OFL，可商用/嵌入/隨 H5 散布，無授權風險；圓潤風格契合可愛 RPG 調性。
- **實作要點**：Godot 字型查找為「主字型 → fallback」。**主字型設 Baloo 2（英數先命中），openhuninn 設為 fallback（補中文）**；切勿反向。建議對中文字型做 subset 子集化以縮小 H5 載入。
- **影響**：`Assets/placeholders/fonts/ui_theme.tres`、`project.godot`（[gui] theme/custom）、H5 export 體積；交由 Codex 在 Godot 編輯器完成匯入/fallback/重新 export 驗證。

## D-010：美術文件集中到 `Art/` 文件中心
- **問題**：美術相關文件散在 `Planning/`（合約、風格、mockup）與 `Assets/`（manifest），美術同事 clone 後沒有單一入口（無 START HERE）。
- **人類決策**：開 `Art/` 作為**美術文件中心**（人看的文件）。`Assets/` 的二進位產線（placeholders/generated/final/fonts）**維持原地不動**（res:// 路徑綁定，不可搬）。
- **搬遷**：`Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md → Art/ART_CONTRACT.md`（內容不變，仍 v1.0 locked，僅換路徑）、`Planning/04_ART_DIRECTION_NOTES.md → Art/ART_DIRECTION_NOTES.md`、`Planning/ui_mockup_battle.png → Art/references/`。新增 `Art/README.md`(START HERE)、`Art/ARTIST_QUICKSTART.md`(Magnific 產線+Claude Code 角色)、`Art/prompts/magnific_prompts.md`。
- **保留**：`Assets/ART_ASSET_MANIFEST.md` 留在 `Assets/`（與實體素材 locality；Codex/08 在該處讀），由 `Art/README` 連過去。
- **原因**：給美術同事一個清楚入口；同時遵守「會被機器讀的路徑不可亂搬」(D-006 教訓)。
- **影響**：全 repo 對上述三檔的引用已同步更新（AGENTS/README/Codex/08/Docs/04/OPEN_QUESTIONS/manifest/Assets READMEs/Planning/01/06 等），無斷連。`ART_CONTRACT.md` 為路徑搬遷非內容變更，不觸發 Freeze 變更程序。

## D-011：背景改為分區（資料驅動，Contract 升 v1.1）
- **問題**：要支援多張背景做「分區」變化，但素材清單屬 Contract 鎖定項。
- **流程**：經 `Q-ART-001` 提出 → 人類核准 → Art Contract `v1.0 → v1.1`（正規 Freeze 變更示範）。
- **人類決策**：3 張背景、分區制——關 1–3 用 `background_battle_001`、4–6 用 `002`、7–10 用 `003`。
- **實作（資料驅動 + 可擴充）**：
  - `Data/game_balance.json > background_zones`：`zones[]`（from_stage/to_stage/background_id）+ `default_background_id` + `fallback_background_id`。要加場景只要加 zone/檔，命名續用 `background_battle_004…`。
  - manifest 新增 `002/003`（recommended）；`001` 仍 required。
  - **缺檔不崩**：某 zone 背景缺 → 退 `fallback_background_id`（001）→ 再退漸層 placeholder。
- **接入**：Codex 在 `task 08` 讀 `background_zones`、依「即將挑戰的關卡」切換 `BattleScene` 背景；需在 Godot 目視確認。
- **影響**：`Art/ART_CONTRACT.md`(v1.1)、`Assets/ART_ASSET_MANIFEST.md`、`Data/game_balance.json`、`Docs/06`、`Codex/08`。

## D-012：UI 採「程式皮膚 + icon 貼紙」（Contract 升 v1.2）
- **問題**：UI 要貼齊貓咪參考圖；agent-sprite-forge 生成的框貼圖描邊太細、無法控制粗細/顏色。
- **流程**：經 `Q-ART-002` 提出 → 人類核准 → Art Contract `v1.1 → v1.2`。
- **人類決策**：
  - 面板/按鈕/chip 的**外框與底色由程式 `StyleBoxFlat` 畫**（深藍 8px 描邊、圓角 32/28、柔和陰影），不使用美術框貼圖。
  - 數字/標題份量用 `Label outline_size`（深藍）補。
  - UI 美術只需 **icon 貼紙**（生成）；實際載入 `runtime/<id>_48.png`，全尺寸為母檔。
- **原因**：粗描邊/份量用程式參數最可控、可量化、確定性命中（task 10 Round 2/2.1 的教訓：別把結構性描邊交給生成圖）。
- **實作**：`Scripts/ui/ui_skin.gd`（`_flat_box`/`_sticker_box`）；移除未使用的框/chip 貼圖與其 const。
- **影響**：`Art/ART_CONTRACT.md`(v1.2)、`Assets/ART_ASSET_MANIFEST.md`（新增 UI icon 區段）、`Scripts/ui/ui_skin.gd`、`Codex/10`。
- **修訂（Round 3，2026-06）**：純程式 StyleBoxFlat 雖份量達標，但缺插畫質感（柔和漸層/貼紙立體感）。經 `Codex/10` Round 3 試做並由人類確認後，**HUD 三欄卡 + 下方操作區（下注面板/按鈕/籌碼）改用生成的 9-slice 貼圖皮膚 `skin_*.png`（`StyleBoxTexture`）**；`apply_panel`/`apply_button` 改為 `_skin_or_sticker_box`（有 skin 用貼圖、缺圖 fallback StyleBoxFlat，不退步）。其餘元件（ProfileFrame/SettlementPanel/ribbon）仍程式畫。文字仍 Label、不動節點結構。新增素材見 manifest「9-slice 皮膚」表。此為 D-012 的**精煉非反轉**（程式畫仍是 fallback 與其他元件的方案）。

## D-013：sprite sheet 規則修正（尺寸上限 + 允許 grid，Contract 升 v1.3）
- **問題**：`ART_CONTRACT` §七 原本只寫「horizontal sprite sheet」且**未設尺寸上限**。設計師照做出 `hero_idle` 25 格 × 768 = **19200×768** 單列圖，**超過 H5/WebGL 與手機 GPU 材質上限**（常見 4096~16384）→ 會載不出/破圖。
- **釐清責任**：**設計師無誤**（嚴格照文件做）；**是規格缺陷**（範例僅 6 格，未預期大格數、未設上限）。前一輪 AI 建議「改 grid」時也未先查合約、與當時 locked 文字相矛盾——本決策正式把規則補正。
- **流程**：`Q-ART-003` → 人類核准 → Contract `v1.2 → v1.3`。
- **決策（§七 新規則）**：
  - sprite sheet 圖檔**單邊 ≤ 4096px**（硬上限）。
  - 格數少（總寬 ≤ 4096）可單列 horizontal；**格數多必須 grid**，JSON 必填 `columns`/`rows`（`columns*rows ≥ frame_count`）。
  - 影格順序：左→右、上→下。
- **行動**：現成 `hero_idle_sheet`（19200×768）請設計師重出 grid（25 格 → 5×5 = 3840²）；`Codex/08` 接入時依 `columns`/`rows` 切格成 `SpriteFrames`/`AnimatedSprite2D`。
- **影響**：`Art/ART_CONTRACT.md`(v1.3 §七)、`Art/ART_SPEC_SHEET.md`、sheet `.json` schema、`Codex/08`。

## D-014：正式接入音效/音樂（修訂 D-008，回應 Q-004）
- **問題**：D-008 定 MVP 不做音效、只留接口。任務卡 01–10 皆完成，MVP 前提已消失；人類指示正式接入音效。
- **流程**：`Q-004` 提出（含選項與 AI 建議）→ 人類採納全部 AI 建議。音訊素材不屬 `Art/ART_CONTRACT.md` 鎖定範圍（合約只管視覺素材），不觸發 Freeze 變更程序、不升 Contract 版本。
- **人類決策**：
  1. **範圍**：BGM + 既有 9 個 SFX 事件的**播放能力**（事件清單見 `Docs/SFX_TODO.md`，不得擅增事件 ID）。SFX 音檔可分批補齊；**有檔才播、缺檔靜音，遊戲不可壞**。
  2. **素材路徑**：`Assets/final/audio/` 為唯一正式音訊入口（比照 D-004 final 原則）。BGM 命名 `bgm_main.ogg`（由工作區 `Assets/FishAlleyQuest.mp3` 於 Godot 編輯器內改名移入）；SFX 命名 `sfx_<event_id>.ogg`（或 mp3/wav）。**不設 placeholder 音檔**——缺檔的 fallback 就是靜音。
  3. **資料驅動**：新增 `Data/audio.json`（event_id→檔名映射、音量、BGM loop），schema 見 `Docs/06`；禁止在腳本寫死檔名/音量（AGENTS 鐵則 6）。
  4. **H5 音訊解鎖**：首次使用者互動時解鎖並開始播 BGM；解鎖前所有播放呼叫靜默略過（`Docs/07` §三由 Future 轉正式）。
  5. **不做靜音/音量 UI**：避免動版面（D-006 不變量），列 Future。
- **原因**：接口（`AudioService.play_sfx` 空殼 + 9 個呼叫點）本就是 D-008 為此刻預留的擴充點；本決策是啟用而非推翻架構。方法簽名不變，既有呼叫點零修改。
- **與 D-008 關係**：**修訂/接續**——D-008 的「預留接口」設計保留並啟用；「不載入音檔、不發聲」的限制自本決策起解除。缺檔時的行為（靜音不崩）即回到 D-008 狀態。
- **實作**：交由 `Codex/11_AUDIO_INTEGRATION.md` 執行（驗收見 `VALIDATION_CHECKLIST` 里程碑 — 任務 11）。
- **影響**：`Scripts/services/audio_service.gd`（空殼→實作）、`Data/audio.json`（新增）、`Docs/06`（+audio schema）、`Docs/07`（§三音訊解鎖轉正式）、`Docs/SFX_TODO.md`（升級為接檔狀態對照表，由 task 11 更新）、`AGENTS.md`（D-008 摘要行、任務卡順序）。

## D-015：線上身分與分數服務（Firebase BaaS，回應 Q-005）
- **問題**：遊戲要能 Google 登入並記錄自己的分數，且展示「AI 併用 CLI 與瀏覽器自行完成雲端佈建」作為比賽亮點；但 AGENTS 鐵則 2 禁止擅增「後端」。
- **流程**：`Q-005` 提出（含選型與六個子項）→ 人類採納全部 AI 建議。
- **人類決策**：
  1. **選型**：Firebase（Auth + Firestore + Hosting）。**BaaS、零自建伺服器**——本服務定名「線上身分與分數服務」，不屬鐵則 2 意義的自建後端；鐵則 2 補充此定位。
  2. **H5 執行緒取捨**：Web export **關閉 thread support**，免除 COOP/COEP 標頭需求，讓 Google OAuth popup 可用。**任務 12 的首項驗收就是此技術驗證**，驗證不過則回到本決策重議。
  3. **fallback 契約**：未登入/離線/初始化失敗/非 Web 平台 → 自動退回 `LocalScoreService`，遊戲完整可玩不崩（同 D-004/D-014 原則）。core 只認 `ScoreService` 介面，不得直接認識 Firebase。
  4. **範圍**：MVP 只做「登入 + 自己的分數」；排行榜與任何讀他人資料功能列 Future。
  5. **佈建方式**：CLI 能做的用 CLI，Console 獨有步驟用 AI 瀏覽器操作；**憑證/密碼一律由人類親手輸入，AI 不經手**；全程截圖存證。
  6. **部署**：`export/web/` 部署至 Firebase Hosting（與 auth 同源）。
- **原因**：task 05 的 `ScoreService` 介面本就是預留的擴充點；BaaS 讓 solo 開發者零維運；佈建過程本身是比賽的展示素材。
- **實作**：`Codex/12_CLOUD_PROVISIONING.md`（執行者 Claude）→ `Codex/13_ONLINE_SCORE_INTEGRATION.md`（執行者 Codex），規格見 `Docs/08_ONLINE_SCORE_SPEC.md`。
- **影響**：`AGENTS.md`（鐵則 2 補充、必讀清單、任務卡順序、決策摘要）、`Docs/07`（§二§三：threads 關閉、COOP/COEP 解除）、`Docs/08_ONLINE_SCORE_SPEC.md`（新增）、`Firebase/` 資料夾（佈建後進版控）、`Scripts/services/online_score_service.gd`（任務 13 新增）。

## D-016：輕量排行榜式非同步競爭（回應 Q-006，D-015 Future 項目啟用）
- **問題**：D-015 全鏈路上線後，如何加入「跟別人比」的體驗而不動核心玩法。
- **人類決策**（2026-07-04，附四張 UI mockup 為視覺目標）：
  1. **單局流程完全不變**（下注→挑戰→打怪→撤退/續戰→結算→再來一局）。排行榜是**疊在上面的 UI 與資料回饋層**。
  2. **四個接觸點**：(i) 下注畫面小型「排行榜」入口；(ii) 決策畫面「目前最佳/若現在撤退約排第幾」提示；(iii) 撤退成功結算：目前排名+超過百分比+個人最高+排行榜入口；(iv) 失敗結算：本次最深進度+超過百分比+目前最佳排名+排行榜入口。
  3. **明確不做**：每日挑戰、同種子模式、模式選擇、即時連線、房間、複雜非同步賽制。
  4. **分階段**：**Phase 1（MVP）用 `MockLeaderboardService`**（資料驅動的 NPC 名單，同一資料結構與介面）；**Phase 2 換 Firebase 實作**（`leaderboard/{uid}` 集合、登入可讀、僅本人可寫、單調遞增驗證）。介面先行，換後端不動 UI 與 core。
  5. **排名指標單一化**：一律以 `best_payout` 比較。排名 = 比你高的人數+1；百分比 = 比你低的人數/總數。失敗畫面的「超過 X%」用死前的 `current_payout` 對照他人最佳紀錄；「本次最深進度」為本局統計（stage），不進排行榜。
  6. Mock 名單為**明示的 NPC 資料**（`Data/leaderboard_mock.json`，可調），demo 對評審說明為模擬資料；Phase 2 上線後移除。
- **原因**：撤退時機判斷是本遊戲核心樂趣，「知道自己排第幾」直接強化它；Mock 先行讓 UI/體驗先完整，Firebase 只是換資料來源（防作弊定位承 Q-006 (c)：內部信任 + rules 底線，伺服器驗證需付費方案列 Future）。
- **實作**：`Codex/15`（LeaderboardService 介面 + Mock 實作 + 本局統計，Codex）→ `Codex/16`（四接觸點 UI，Codex，依 mockup）→ `Codex/17`（Phase 2 Firebase 實作，Claude，人類另行啟動）。
- **影響**：`Scripts/services/`（+leaderboard_service.gd/mock_leaderboard_service.gd）、`Data/leaderboard_mock.json`（新）、`Data/ui_text.json`、四張 mockup 入 `Art/references/`、manifest（+icon_trophy 等）、`Docs/08` §八、`AGENTS.md`。

## D-017：怪物素材接入——動畫序列圖 + boss/ 子資料夾（回應 Q-ART-004，Contract 升 v1.4）
- **問題**：美術交付九隻怪物的 idle 動畫序列圖（`Assets/final/boss/bossN_idle.png/.json`，
  TexturePacker 格式），命名/路徑與 Contract v1.3 §二清單（靜態 `monster_00N_idle.png`）不符；
  第 10 隻未交付。
- **實測**：九張皆 3072×2304（4×3、768px 框、12 幀），符合 §七 ≤4096 上限；JSON 含明確
  frame 座標與 `meta.animations`，優於 columns/rows 最低要求。
- **人類決策**（2026-07-05）：
  1. **素材照現狀接入**，不要求美術改名重交——文件配合現實（同 D-013 精神：規格服務交付，
	 不折騰設計師）。
  2. Contract `v1.3 → v1.4`：§二怪物條目改為動畫序列圖、§四允許 `Assets/final/boss/` 子資料夾、
	 §七接受 TexturePacker JSON（frames + meta.animations）為 sheet 中繼資料格式。
  3. **第 10 隻維持 placeholder**（缺檔 fallback 不阻塞，D-004 原則），日後補檔即自動接入。
- **對映**：`Data/monsters.json` 的 stage N（1–9）↔ `boss<N>_idle`；idle 動畫時長仍讀
  `animation_timing.json`（鐵則 6）。
- **實作**：`Codex/18_MONSTER_ASSET_INTEGRATION.md`（Codex 執行，含 H5 實機驗證——
  VALIDATION_CHECKLIST 通用段的 ResourceLoader/實機規則適用）。
- **影響**：`Art/ART_CONTRACT.md`(v1.4)、`Assets/ART_ASSET_MANIFEST.md`、`Data/monsters.json`、
  `Scripts/actors/monster_actor.gd`、`Assets/ART_MISSING_CHECKLIST.md`（美術交付現況文件）。

## D-018：背景素材改以 JPG 交付 + 副檔名優先序解析（回應 Q-ART-005，Contract 升 v1.5）
- **問題**：美術交付背景新版 `background_battle_001/002/003.jpg`（1080×1920 滿版），格式與
  Contract v1.4 §三/§五（PNG-only）不符；`ART_SPEC_SHEET.md` 原已註明 JPG 需走 Q-ART。
- **實測**：三張皆 1080×1920（優於舊 png 版 001 的 941×1672）；約 300KB/張 vs 舊 png 約
  2.2MB/張，Web 版載入量大幅下降。
- **人類決策**（2026-07-06，已在 Godot 目視驗收）：
  1. **JPG 版本照現狀入庫**，成為現行背景素材——同 D-013/D-017 精神：文件配合現實交付。
  2. Contract `v1.4 → v1.5`：§三/§五 修訂——**不透明全幅背景圖允許 JPG**；角色/怪物/特效/
	 Logo 等需透明素材仍限 PNG（32-bit alpha）。
  3. **程式配套**：背景解析依副檔名優先序嘗試 `.jpg` → `.jpeg` → `.png`（`battle_presenter.gd`）；
	 缺檔 fallback 鏈（zone 背景 → `fallback_background_id` → 漸層 placeholder）不變（D-011）。
  4. 舊 `.png` 三張**暫留庫中**作備份；是否移除以縮小 Web 匯出體積，另行決定。
- **原因**：背景不需 alpha，PNG-only 是對「角色需透明」的過度概括；JPG 對全幅照片式底圖
  是正確格式，且直接改善 H5 載入。
- **影響**：`Art/ART_CONTRACT.md`(v1.5)、`Art/ART_SPEC_SHEET.md`、`Assets/ART_ASSET_MANIFEST.md`
  （背景列）、`Scripts/battle/battle_presenter.gd`、`Assets/final/background_battle_00[1-3].jpg`（新增）。

## D-019：賭場化體驗改版——拿血條、賠率語言、每局隨機倍率盤（回應 Q-007）
- **問題**：比賽準備階段的體驗強化三題：血條去留、倍率隨機化、成功率顯示策略。
- **人類決策**（2026-07-07，對話中裁示，照 AI 建議採納）：
  1. **移除血條顯示，換成危險度指示**：勝負實由 success_rate 在進關瞬間決定，血條是
	 誤導演出。`MonsterHpBar` 不再顯示，原位置改放危險度等級圖示（資料驅動分級，
	 `game_balance.json > danger_display` 依該關 success_rate 對映 1–5 級）。
	 戰鬥演出內部血量邏輯（傷害節奏計算）保留不動。
  2. **每局隨機倍率盤（漸進成長）**：每局下注確認時以 `multiplier_curve` 為基準擲一次
	 「本局盤」——每關套隨機抖動、強制單調遞增（`本關 ≥ 前關 × min_growth_ratio`）；
	 抖動幅度隨關卡線性放大（低關穩、高關瘋）。參數入
	 `game_balance.json > multiplier_random`（enabled 開關保留回退路徑）。
	 **success_rate 維持固定不連動**——各局期望值自然浮動是特色不是 bug。
	 揭示規則：**只揭示下一關倍率**，不提供全曲線預覽。
	 已知副作用（接受）：排行榜 `best_payout` 運氣成分變大。
  3. **不顯示精確成功率 %，改博奕語言**：獎金放大（決策畫面主打「過關可得 {金額}」、
	 賠率格式「1 賠 N」）、風險質化（危險度圖示，承 1）；術語：續戰=「過關」、
	 撤退=「落袋為安」；結算加 FOMO 事後揭示（撤退：「若再過一關可得…」；
	 戰敗：「上一關落袋本可帶走…」）。
  4. **文案契約**：所有句子先按博奕術語寫入 `Data/ui_text.json`（鐵則 6），
	 **人類保留事後直接改 json 換句子的權利**——程式只認 key 與 `{變數}`，
	 不得依賴字串內容；已烙字在圖上的按鈕素材（next/retreat.png）文字不在本案範圍，
	 要換走 Q-ART。
- **原因**：遊戲核心樂趣是進退抉擇不是打怪；把注意力從假戰鬥移回真賭注。賭場鐵律
  「放大獎金、隱藏機率」+ FOMO 事後揭示是「再來一局」衝動的主要來源；倍率隨機化
  解決固定曲線玩兩次就背起來的問題。
- **實作**：`Codex/20_DECISION_INFO_REVAMP.md`（血條→危險度 + 賠率語言 + FOMO 結算；
  Codex）→ `Codex/21_RANDOM_MULTIPLIER_TABLE.md`（每局隨機倍率盤；Codex）。
  卡 20 涉及場景版面，依 D-006 需 Godot 目視驗證。
- **影響**：`Data/game_balance.json`（+`danger_display`、+`multiplier_random`）、
  `Data/ui_text.json`、`Scripts/core/game_state_machine.gd`、
  `Scripts/battle/battle_presenter.gd`、`Scripts/ui/`（決策/結算）、
  `Scenes/UI/VerticalUi.tscn`（決策區資訊）、`AGENTS.md`、`Codex/VALIDATION_CHECKLIST.md`。

## D-020：排行榜 NPC 保底名單於正式版保留（修訂 D-016 §6「Phase 2 上線後移除」）
- **問題**：比賽 demo 期間真實玩家極少，雲端排行榜近空——空榜比假榜更傷展示效果。
- **人類決策**（2026-07-08，對話中裁示）：初始 NPC 假資料**即便部署了也要保留在排行榜上**。
- **實作方式（AI 選型，client 端合併，不寫雲端）**：
  1. `Data/leaderboard_mock.json` 新增 `keep_in_production: true`（schema 1.1）——
	 一鍵可關，設 false 即回 D-016 原行為；NPC 名單本身仍是同一份 json。
  2. `FirebaseLeaderboardService`：登入時把 NPC 名單與 Firestore 資料在 client 端
	 合併重排名（competition ranking）；排名/超越百分比計算同步併入 NPC 計數。
	 未登入/橋接缺失/雲端失敗 → 整份退回 Mock 語意（**排行榜永不空**，且未登入
	 也看得到榜，比原「空列表」體驗更好）。
  3. `Firebase/web/crush-online.js` 的 `fetchRankFor` 回傳補 `higher/lower/total`
	 原始計數（向下相容；GDScript 對舊版 bridge 有退化路徑）。
  4. **不寫任何假資料進 Firestore**：rules 不動、雲端資料保持純真實玩家，移除保底
	 只需改 json flag。
- **誠實聲明**：對評審展示時說明榜上混有模擬 NPC（沿用 D-016 §6 的揭露原則）。
- **影響**：`Data/leaderboard_mock.json`、`Scripts/services/firebase_leaderboard_service.gd`、
  `Firebase/web/crush-online.js`（需重新部署 hosting 才對舊版 bridge 生效）、`AGENTS.md`。

## D-021：Claude 可在 HTML 預覽截圖驗證下直接修 UI 版面（放寬 D-006 的執行者限制）
- **背景**：本機已建立 HTML 預覽迴圈（`.claude/launch.json` 的 `web-preview`：
  Python 靜態伺服器供應 `export/web/`；改動 → Godot 無頭匯出 → 硬刷新 → 截圖）。
  Claude 據此比對 `Art/references/ui_mockup_battle.jpg` 找出未對齊項並可自行驗證。
- **人類決策**（2026-07-09，對話中裁示「你直接修改就好」）：mockup 對齊類的版面
  修改，Claude 可直接動 `Scenes/*.tscn` 與 UI scripts，**以匯出後截圖目視驗證取代
  Godot 編輯器內人工目視**。D-006「不可盲改」精神不變——改完必須附截圖證據；
  無法用截圖驗證的（動畫手感、觸控行為）仍回 D-006 原流程。
- **本輪範圍**（比對 mockup 的未對齊項）：
  1. ＋／－按鈕放大至接近 mockup 的方形糖果鈕比例，金額字級放大。
  2. 「玩家排行」膠囊比照 mockup 在關卡進行中也顯示（原僅下注時顯示）。
  3. 怪物名稱裸文字改套浮層藥丸樣式（與危險度列一致）。
  4. 左上圓形貓頭像徽章**不做**——無現成素材，新增美術走 Q-ART（見 ART_CONTRACT）。
- **影響**：`Scenes/UI/VerticalUi.tscn`、`Scripts/ui/ui_skin.gd`、
  `Scripts/ui/vertical_ui.gd`、`Docs/DECISIONS.md` 本檔。
- **同日修訂（2026-07-09 人類複核兩輪）**：
  a. 名牌藥丸與危險度藥丸重疊（名牌 y680–760 vs 危險度 y752 起）→ 名牌改
	 580–980×700–760、危險度錨改血條上緣 +4 並以血條中心水平置中。
  b. 人類再裁示：名牌**不要底框**，改貼紙風彩字（粉紅字＋奶油描邊＋深藍陰影）；
	 危險度藥丸太長 → 取消 400px 寬度下限改貼內容收窄（爪印 53→46px、間距與
	 padding 同縮）。
  影響追加：`Scenes/Main.tscn`、`Scripts/battle/battle_presenter.gd`、
  `Scripts/ui/bet_panel.gd`（±鈕座標的 runtime 覆蓋落點在此）。
  c. 第三輪複核：藥丸仍太長且爪印縮小不可接受 → 爪印恢復 53px，**戰場藥丸只放
	 爪印、「危險度」字樣隱藏**（語意教學由決策資訊卡的「危險度＋爪印」承擔）；
	 缺圖時星號文字保底照舊顯示（D-004 不崩原則不變）。
  d. 第四輪複核（定案）：「危險度」三字要留。因藥丸寬＝內容橫排總和（字＋大爪印
	 一橫排必回 400+px），改**上下兩行**：26px「危險度」在上、53px 爪印列在下，
	 框寬只由爪印列決定（約 309px）。缺圖星號保底不變。
  e. 第五輪複核（真定案）：兩行式深色藥丸整塊太寬太醜。最終落點＝**「危險度」
	 26px 小字無框浮在名牌下（與名牌同款輕量處理），深色藥丸只包 53px 爪印列
	 （約 309px 寬、65px 高）**。全無框方案已實測否決——未亮爪印無論半透明白
	 或深藍剪影，在花背景（暗圍籬段）都會隱形，深色藥丸是爪印可讀性的下限。
	 缺爪印圖時藥丸整顆隱藏、浮字改星號保底。
  f. 最終裁示（人類）：危險度顯示**整組恢復原始版本**（git HEAD 的
	 battle_presenter＋Main.tscn＋overlay_pill 20px padding——單一橫排藥丸、
	 「危險度」32px 字＋53px 爪印、錨血條上緣 -12、寬度下限 400px）。
	 戰場浮層本輪唯一保留的改動＝**名牌樣式**（無框粉紅貼紙字，見 b）。
	 a–e 的迭代記錄保留作為「試過且被否決」的路徑清單。

## D-022：「遇見虎爺」隨機救援事件——敗局強制逆轉＋該關增額翻倍
- **問題**：比賽準備階段想加一個博奕遊戲式的特殊獎勵事件（FREE GAME 感），提案為
  「遇見虎爺」：怪物反擊時超慢動作，虎爺從天而降壓飛怪物（卡通式往左上旋轉縮小
  飛出螢幕），配大字插頁與虎爺對話框，獎勵加倍。
- **人類決策**（2026-07-11，對話中裁示）：
  1. **觸發語意＝強制逆轉勝**：每次發起挑戰（下注確認/續戰）時以獨立 RNG 擲一次；
	 骰中則本關保證上演「怪物反擊 → 虎爺壓飛」逆轉戲，**蓋過原本的勝負骰**，
	 判定為勝、算過關繼續前進。
  2. **x2 範圍＝只有該關的增額翻倍**：觸發關的收益增額（本關收益 − 前一關收益）
	 額外再加一份，之後各關照常成長；bonus 為固定加項保留到結算，戰死照樣全失。
	 一局內可重複觸發（各自加各自的增額，機率使然罕見）。
	 **【2026-07-11 同日修訂（人類再裁示，取代本項）】x2 範圍改為「本局收益翻倍」**：
	 觸發時本局收益倍率整體乘上 `payout_factor`（預設 2.0），乘進
	 current/next multiplier（顯示倍率與計算同源），延續到撤退/通關結算；
	 之後各關在翻倍後基礎上照常成長；多次觸發疊乘；戰死照樣全失。
	 `reward_mode` 由 `stage_increment_x2` 改為 `run_payout_x2`。
	 banner 烙字「本次收益倍率翻倍！」維持原圖（機制改為與圖一致）。
  3. **機率 5%**，入 `game_balance.json`（資料驅動，隨時可調）。
  4. **附 demo 強制觸發開關**（debug 欄位），供比賽展示/錄影/截圖；另設 `enabled`
	 總開關作回退路徑（false＝事件不存在，行為與現況相同，仿卡 21 慣例）。
- **既知副作用（接受）**：期望值小幅上升（可日後在倍率盤參數吸收）；排行榜
  `best_payout` 運氣成分再放大（D-019 已接受同類副作用）。
- **實作**：`Codex/24_HUYE_RESCUE_EVENT.md`（Codex）。虎爺骰用獨立 RNG，
  不得污染 risk_resolver 成功率骰序列與卡 21 倍率盤 `_rng`。
- **素材**：虎爺貼紙走「生成暫代 → 設計師 git 覆蓋同檔名」模式（title_banner 先例）；
  規格登記 `Assets/ART_ASSET_MANIFEST.md`，屬既有貼紙類別，不動 ART_CONTRACT。
- **影響**：`Data/game_balance.json`（+`random_events`）、`Data/animation_timing.json`
  （+`effects.huye_event`）、`Data/ui_text.json`、`Scripts/core/game_state_machine.gd`、
  `Scripts/battle/battle_presenter.gd`、`Scripts/effects/`（新演出）、
  `Assets/ART_ASSET_MANIFEST.md`、`AGENTS.md`、`Codex/VALIDATION_CHECKLIST.md`、
  `Docs/06_DATA_SCHEMA.md`。

## D-023：金幣噴發音效獨立事件（修訂 D-019/卡 19 的併檔備註）
- **問題**：卡 19 當時裁示「金幣聲併入 `monster_death` 音檔，不另增事件」
  （見 `Docs/SFX_PRODUCTION_LIST.md` 搜尋指南備註）。實際聽感金幣感不足，
  且虎爺獎勵的金幣噴發（卡 24 復用 CoinBurst）完全無聲。
- **人類決策**（2026-07-13，對話中裁示）：
  1. **音效拆分**：`monster_death` 現行音檔保留，專職怪物死亡聲；金幣噴發
	 獨立為新 SFX 事件。
  2. **兩個噴發事件**：`coin_burst`（怪物死亡噴發）與 `huye_coin_burst`
	 （虎爺獎勵噴發，更盛大加長版）——虎爺場的中獎感值得獨立音檔。
  3. **素材由人類自行蒐集**：程式先接事件與 `audio.json` 映射，缺檔靜音
	 （D-014 慣例），之後放檔即接上、零程式改動。
- **影響**：`Scripts/effects/coin_burst.gd` 或 `Scripts/core/game_controller.gd`
  （播放點）、`Data/audio.json`、`Docs/SFX_PRODUCTION_LIST.md`、
  `Codex/VALIDATION_CHECKLIST.md`。
- **實作**：`Codex/25_COIN_BURST_SFX_SPLIT.md`（Codex）。

## D-024：事件型 BGM——虎爺降臨切換專屬 BGM（超出 D-014 九事件範圍的擴充）
- **問題**：虎爺事件演出偏乾。博奕遊戲 FREE GAME 慣例：觸發特殊事件時
  切換專屬音樂，事件結束接回主 BGM。
- **人類決策**（2026-07-13，對話中裁示）：
  1. **切換語意**：進虎爺事件（慢動作開始）主 BGM 淡出，播虎爺專屬 BGM；
	 事件收尾（獎勵金幣噴發完成）虎爺 BGM 淡出、主 BGM 淡入。
  2. **主 BGM 接續原播放進度**（記錄切出位置續播，非從頭重播）。
  3. **虎爺 BGM 必須可循環**：banner 等玩家點擊、事件時長不定。
  4. **資料驅動**：`Data/audio.json` 新增頂層 `event_bgm.huye`
	 （file/loop/volume_db/fade_out/fade_in）。缺檔 → 不切換、主 BGM 照播
	 （D-004 不崩原則），事件其他演出照常。
  5. **順手命名統一**：事件 ID `sfx_huye_appear` 改 `huye_appear`
	 （與其他九事件裸名慣例一致；音檔檔名維持 `sfx_` 前綴）。
- **影響**：`Scripts/services/audio_service.gd`、`Scripts/core/game_controller.gd`、
  `Data/audio.json`、`Docs/06_DATA_SCHEMA.md`、`Docs/SFX_PRODUCTION_LIST.md`、
  `Codex/VALIDATION_CHECKLIST.md`。
- **實作**：`Codex/26_HUYE_EVENT_BGM.md`（Codex）。

## D-025：虎爺事件大獎節奏重分配＋程式衝擊特效
- **問題**：2026-07-15 實跑確認，虎爺事件不是整段一律太短，而是重拍失衡：
  `slow_hold=0`、下墜僅 `0.12s`、`impact_hold=0`，使虎爺出現到落地過急；
  相反地 `pre_banner_delay=1.0s` 令爆點後出現死空氣，不像遊戲的大獎事件。
- **人類決策**（2026-07-15，對話中裁示）：
  1. 演出重排成「危機定格 → 神明降臨 → 落地爆點 → 大獎揭曉」四拍，
	 把部分 post-impact 空等搬到下墜前懸念與落地後確認。
  2. 可新增克制的 jackpot 特效：金色漂浮光屑、下墜拖尾、落地白金閃光、
	 shockwave、火花／塵霧、banner 紙屑；獎勵金幣仍只由既有 CoinBurst 負責。
  3. 不用 `Engine.time_scale`，不動狀態機、勝負、收益與 x2；所有調校數值
	 資料驅動，並提供 `jackpot_fx.enabled=false` 回退。
  4. 特效以程式元件完成，不新增正式美術；粒子 one-shot、自動釋放、H5 同時
	 存活量建議不超過 100。
  5. **2026-07-15 人類追加裁示**：慢速顯形起始新增 `huye_divine_reveal`
	 SFX，映射 `sfx_huye_divine_reveal.ogg`；與落地幀的 `huye_appear` 分工，
	 缺檔仍依 D-014 靜音略過、不影響演出。
  6. **2026-07-15 人類追加裁示**：虎爺壓死怪物後、獎勵金幣從怪物位置
	 噴出時播放既有 `coin_burst`；`huye_coin_burst` 改在虎爺事件 Modal
	 成功彈出時播放，關閉 Modal 後不得重複播放。
- **影響**：`Data/animation_timing.json`、`Scripts/battle/battle_presenter.gd`、
  `Scripts/effects/huye_banner.gd`、新增獨立 jackpot FX script、
  `Docs/06_DATA_SCHEMA.md`、`Codex/VALIDATION_CHECKLIST.md`。
- **實作**：`Codex/27_HUYE_JACKPOT_PACING_AND_FX.md`（Codex）。
