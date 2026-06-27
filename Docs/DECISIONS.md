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
- **決策**：`Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md` 一旦標 `v1.0 locked`，其鎖定項目（必要素材清單、檔名/路徑、透明背景、角色面向、背景比例、placeholder/generated/final 流程、Godot 匯入方式、Codex 預期讀取檔名）**不得直接改檔**。
- **變更程序**：`OPEN_QUESTIONS.md`（Q-ART-XXX）→ 本檔新增決策 → 評估影響（任務卡/manifest/Data）→ 人類同意後升 `v1.1`。
- **原因**：固定 Codex 與美術的契約面，允許風格自由但接口穩定。
- **影響**：`README`、`Planning/01`、`Planning/03`、`Codex/00`、`Codex/08`、`Assets/ART_ASSET_MANIFEST.md`。

## D-003：美術風格由美術同事決定，Claude 只定規格
- **問題**：AI 是否該決定美術風格？
- **決策**：明確區分 **Art Contract（不可變，Claude/人類定）** 與 **Art Direction（可變，美術同事定）**。
  Claude 只負責「Godot/Codex 可接入的規格合約」，不替美術同事定死長相/色彩/筆觸/風格。
- **原因**：發揮人類美術判斷，AI 專注結構化落地；同時保證可接入性。
- **影響**：`Planning/03`（合約）、`Planning/04`（風格筆記，美術主筆）、`ART_ASSET_MANIFEST.md`。

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
- **影響**：`Planning/03`、`Planning/06`、`Codex/00`、`Codex/08`、`Assets/*/README.md`、`.gitignore`。

## D-005：DataLoader 改為 autoload 單例 `Data`
- **問題**：任務 01 的 `DataLoader` 是 `game_controller` 的私有成員，但任務 02 起的狀態機/收益/判定都需要同一份資料，放著會各自重複載入或互相耦合。
- **選項**：A. autoload 單例 `Data`；B. game_controller 持有並注入傳遞。
- **AI 建議**：A。
- **人類決策**：採 A，已於任務 02 落實並驗證。
- **原因**：資料是全專案共用的單一真實來源，autoload 最乾淨、避免重複載入。
- **實作**：`data_loader.gd` 改 `extends Node`、`_ready()` 自動 `load_all()`、新增 `is_loaded()`；`project.godot` 註冊 `Data="*res://Scripts/core/data_loader.gd"`。
- **影響**：所有系統透過全域 `Data` 取值，不得各自重新載入。
