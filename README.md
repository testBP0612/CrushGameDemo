# CrushGameDemo — AI 遊戲開發工作流 + Godot H5 風險撤離原型

> 這個 repo 展示的**不只是一款遊戲**，而是一套**可複製、可多人協作的 AI 遊戲開發生產線**，
> 以及防止 AI 發散 / 改方向 / context rot 的**治理機制**。遊戲本身（H5 風險撤離型自動戰鬥）是這條生產線的第一個產物。

## 30 秒看懂
```
企劃書 → AI 規劃(規格/資料) → Codex 任務卡 → Godot 實作 → 驗收清單 → 回饋修正 → 可玩 H5 原型
                    ↑ 人類在 DECISIONS 拍板        ↑ AI 不確定就寫 OPEN_QUESTIONS
```
- **人類定方向，AI 結構化落地。** Codex 只依已確認文件執行，一次一張任務卡。
- **所有協作透過 repo 文件**（不靠聊天上下文）：工程(Codex) + 美術(Magnific) 平行作業。

## 遊戲一句話
手機直式 9:16「風險撤離型自動戰鬥 H5 遊戲」：用虛擬金幣下注，自動戰鬥擊敗怪物，倍率與收益遞增，
隨時可「撤退領取」或「挑戰下一隻」，失敗則本局損失。見 `Planning/00_GAME_PITCH.md`。

## 資料夾地圖
| 路徑 | 責任 |
|---|---|
| `Planning/` | 企劃、AI 工作流策略、人類決策格式、美術規格、簡報、Git 協作（人類決策區） |
| `Docs/` | Codex 必讀規格（設計/系統/狀態機/UI/動畫/資料/H5）+ `OPEN_QUESTIONS` + `DECISIONS` |
| `Codex/` | Codex 主提示 + 8 張任務卡 + 驗收清單（Codex 工作區） |
| `Data/` | 數值與設定的**單一真實來源**（JSON，禁止寫死於程式） |
| `Scenes/` `Scripts/` | Godot 工程（由 Codex 依任務卡建立） |
| `Assets/` | `placeholders/`(Codex 暫代) · `generated/`(可選暫存) · `final/`(唯一正式入口) + `ART_ASSET_MANIFEST.md` |

> **Godot 工程位置**：工程檔（`Scenes/Scripts/Data/Assets`）直接放在 repo root（`project.godot` 已在 root）。
> 企劃範本中的 `GameProject/` 為概念分區，實體即 repo root。理由見 `Docs/DECISIONS.md` D-001。

## Codex 必讀順序
1. `Codex/00_MASTER_PROMPT.md`（鐵則！）
2. `Docs/01`→`07`（設計/系統/狀態機/UI/動畫/資料/H5）
3. 當前任務卡 `Codex/01`→`08`（依序，一次一張）
4. 需要美術時：`Assets/ART_ASSET_MANIFEST.md` + `Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md`

## 治理機制（本專案重點）
- **`Docs/OPEN_QUESTIONS.md`**：AI 不確定**不猜**，先登記等人類回答。
- **`Docs/DECISIONS.md`**：人類拍板的權威紀錄，可追溯。
- **`Codex/VALIDATION_CHECKLIST.md`**：每張任務卡過驗收才往下。
- **Art Contract Freeze** 🔒：`Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md` 標 `v1.0 locked` 後，
  必要素材清單/檔名/路徑/透明/面向/匯入方式等**不得直接改檔**；變更須走
  `OPEN_QUESTIONS`(Q-ART-XXX) → `DECISIONS` → 人類同意 → 升 `v1.1`。詳見 `DECISIONS.md` D-002。

## 美術協作（placeholder-first + art-parallel）
- Codex 第一階段用 **placeholder** 完成遊戲本體，不等正式美術、不碰風格。
- 美術同事平行依 **Art Contract + Manifest** 用 Magnific 產圖；**風格由美術同事決定，Claude 只定接入規格**。
- 候選稿**不進 repo**；確認可用後依 manifest 整理直接放 `Assets/final/`（唯一正式入口）。
- Codex 只讀 `final/` 與 `placeholders/`；**缺檔自動 fallback placeholder，遊戲不可崩**。
- Git 協作細節見 `Planning/06_GIT_COLLABORATION_WORKFLOW.md`。

## MVP / Future / 不做（摘要，詳見 `Planning/00`）
- **MVP**：9:16 H5 可玩閉環、下注/倍率/收益、自動戰鬥演出、撤退/戰敗/通關結算、LocalScoreService+mock、H5 export、前 5 隻怪物美術接入。
- **Future（只預留架構）**：Google Login、排行榜、`ApiScoreService`/`FirebaseScoreService`、反作弊、6~10 隻怪物美術、更多特效。
- **不做**：大型會員/經濟系統、商城、裝備養成、抽卡、大型後端、多人同步、複雜反作弊、真動作戰鬥、複雜怪物 AI、關卡編輯器、Tab Bar、常駐資源列、設定/成就頁。

## 技術
Godot 4.6 · GL Compatibility（Web 相容）· GDScript 分層（core/battle/actors/ui/effects/services）· 資料驅動（`Data/*.json`）。

## 給評審 / 同事的快速路徑
想看**工作流**：`Planning/01` → `Codex/00` → 任一張任務卡 → `VALIDATION_CHECKLIST`。
想看**治理**：`Docs/OPEN_QUESTIONS` + `Docs/DECISIONS` + `Planning/03`(Freeze)。
想**試玩**：依 `Docs/07_H5_EXPORT_SPEC.md` 匯出 Web 後開瀏覽器。
簡報故事線：`Planning/05_PRESENTATION_STORYLINE.md`。
