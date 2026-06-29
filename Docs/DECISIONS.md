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
