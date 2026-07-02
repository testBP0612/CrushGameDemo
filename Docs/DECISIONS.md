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
  2. **素材路徑**：`Assets/final/audio/` 為唯一正式音訊入口（比照 D-004 final 原則）。BGM 命名 `bgm_main.mp3`（由工作區 `Assets/FishAlleyQuest.mp3` 於 Godot 編輯器內改名移入）；SFX 命名 `sfx_<event_id>.ogg`（或 mp3/wav）。**不設 placeholder 音檔**——缺檔的 fallback 就是靜音。
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
