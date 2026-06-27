# 06 — Git 協作工作流（Git Collaboration Workflow）

> 目的：工程（Codex）與美術同事共用一個 repo、且雙方都用 AI 工具時，靠**文件 + 清楚的寫入權責**協作，
> 而非互相踩線。原則：**repo 只管理規格、正式可用素材、Codex 可接入素材**；不管理大量候選稿。

## 一、資料夾寫入權責
| 路徑 | 責任 | 主要可寫者 |
|---|---|---|
| `Planning/` | 企劃、AI 工作流、人類決策、美術規格 | 企劃/工程主 |
| `Docs/` | Codex 必讀規格、狀態機、系統文件 | 企劃/工程主（Codex 僅可追加 `OPEN_QUESTIONS.md`） |
| `Codex/` | 任務卡 | 企劃/工程主 |
| `Data/` | 數值與設定單一真實來源 | 企劃/工程主 + Codex（依任務卡） |
| `Scripts/` `Scenes/` | Godot 工程 | Codex（依任務卡） |
| `Assets/placeholders/` | 開發用暫代素材 | Codex |
| `Assets/generated/` | 可選暫存（非必要、非依賴；候選稿原則不進 repo） | 美術同事（可選） |
| `Assets/final/` | **唯一正式素材入口** | 美術同事 |

## 二、Git 規則（輕量、務實）
- 規格與文件修改都要 commit，message 點出影響範圍（例：`docs: 調整成功率曲線, 影響 Codex 07`）。
- **Art Contract 鎖定後不能直接改檔**，走 `Q-ART-XXX` + `DECISIONS.md`（見 `Planning/01`、`DECISIONS.md` D-002）。
- **候選圖/失敗稿不進 repo**：美術在本機/Magnific 自由探索，確認可用後才依 manifest 整理進 `Assets/final/`。
- 素材進入 `Assets/final/` 即視為符合 Art Contract、可被接入；**無需額外 Git review 流程**。
- `Assets/generated/` 可空著；**Codex 不得依賴**。`.gitignore` 已忽略其內容（保留 README）。
- **Codex 只讀** `Assets/final/` 與 `Assets/placeholders/`。
- **美術同事不要動** `Scripts/`、`Scenes/`、`Data/`（除非有明確任務）。
- **Codex 不要動** `Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md`（除非任務卡要求）。

## 三、`.gitignore` 重點（已設定）
- 忽略 `.godot/`、`.import/`（Godot 匯入快取）。
- 忽略 H5 export 輸出（`export/`、`build/`、`*.wasm`、`*.pck`）。
- 忽略 `Assets/generated/*`（保留其 `README.md` 與 `.gdkeep`）。
- **不引入 Git LFS** 等過度複雜方案；正式素材數量少（前 5 隻怪物 + 主角 + 背景），一般 PNG 體積可接受。

## 四、建議分支策略（簡單版）
- 個人小作品可直接在 `main` 上小步提交；若要更穩，可：
  - `feat/codex-<任務編號>`：Codex 一張任務卡一個分支，完成後合併。
  - `art/<asset_id>`：美術一批素材一個分支。
- 不強制 PR review（溝通成本低時口頭確認即可），但**規格與決策變更建議留 commit 軌跡**以利展示工作流。

## 五、衝突避免要點
- 工程與美術寫入區幾乎不重疊（`Scripts/Scenes` vs `Assets/final`），天然低衝突。
- 唯一交界是 `Data/monsters.json` 的 `art_asset_id` 與 manifest——這由企劃/工程主維護，美術不改。
- 共同依賴 `ART_ASSET_MANIFEST.md` 作為對齊點：檔名以它為準。
