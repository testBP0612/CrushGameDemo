# 01 — AI 工作流策略（AI Workflow Strategy）

## 核心精神：人類負責方向，AI 負責結構化落地
```
AI 提出問題 → 人類回答 → 決策定案（寫入文件）→ Codex 只依已確認文件執行
```
- AI 會提問、會提可行方案、會給建議。
- **人類做最後決策**，決策寫入 `Docs/DECISIONS.md`。
- **Codex 只根據已確認文件執行**，不自行詮釋方向。

## 不追求全自動，而是「AI 可控生產線」
```
企劃書 → 規格文件 → 資料結構 → Codex 任務卡 → Godot 實作 → 驗收清單 → 回饋修正 → 可玩 H5 原型
```
我們刻意**不讓 AI 自動亂做一款遊戲**，而是讓每一步都有文件、有邊界、有驗收。

## 多人 + 多 AI 工具 + Git 文件協作
所有人透過 **repo 文件**協作，而非只靠聊天上下文：

| 角色 | 工具 | 讀什麼 | 寫什麼 |
|---|---|---|---|
| 企劃/工程主 | Claude（規劃）| 全部 | `Planning/`、`Docs/`、`Codex/`、`Data/` |
| Codex | Codex | `Docs/`、`Data/`、`Codex/` 任務卡、manifest | `Scripts/`、`Scenes/`、`Data/`（依卡）、`OPEN_QUESTIONS` |
| 美術同事 | Magnific + AI | `Art/`（START HERE）、`ART_ASSET_MANIFEST` | `Assets/final/`、`Art/ART_DIRECTION_NOTES.md` |

協作流程：
```
AI 產規格 → 人類審核與鎖定規格 → AI/Codex/Magnific 依規格製作 → 人類驗收 → Git 紀錄決策與產物
```

## 防 context rot 的檔案治理
| 機制 | 檔案 | 作用 |
|---|---|---|
| 專案入口 | `README.md` | 一頁看懂全貌與導覽 |
| 人類決策區 | `Planning/` | 企劃與拍板 |
| Codex 工作區 | `Codex/` | 任務卡，一次一張 |
| 不確定登記簿 | `Docs/OPEN_QUESTIONS.md` | AI 不猜，先問 |
| 決策紀錄 | `Docs/DECISIONS.md` | 定案的權威依據 |
| 數值單一真實來源 | `Data/*.json` | 禁止散落寫死 |
| 每輪驗收 | `Codex/VALIDATION_CHECKLIST.md` | 過了才往下 |

## Codex 治理規則總表（完整版見 `Codex/00_MASTER_PROMPT.md`）
1. 不改核心玩法。2. 不加大型系統。3. 不換方向。4. 不明處寫 `OPEN_QUESTIONS`。
5. 一次一張卡。6. 數值/文案不寫死。7. 不堆單一巨大 script。8. 美術限制（只讀 final/placeholders、不生成、缺檔 fallback、不改 Contract）。9. 完成後依格式回報。

## Art Contract Freeze（治理重點）
`Art/ART_CONTRACT.md` 標 `v1.0 locked` 後，其鎖定項目不得直接改檔。
變更必走：`OPEN_QUESTIONS.md`（Q-ART-XXX）→ `DECISIONS.md` → 影響評估 → 人類同意 → 升 `v1.1`。
詳見 `Docs/DECISIONS.md` D-002。

## 為什麼這套能複製到其他遊戲
規格、資料、任務卡、驗收、決策、素材合約都是**檔案**且彼此解耦。換一款遊戲只需替換
`Data/`、`Docs/` 與 `Codex/` 任務卡內容，治理骨架與協作流程不變。
