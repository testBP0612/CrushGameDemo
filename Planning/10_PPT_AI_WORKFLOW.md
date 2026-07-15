# PPT 草稿二：AI 工作流程圖

> 用途：比賽繳交 PPT「AI 工作流程圖」的內容底稿。每個 `## Slide N` 為一頁投影片。
> 流程圖以 mermaid 表達邏輯，最終 PPT 可照結構重繪成圖形（節點文字照抄即可）。
> 事實來源：`Planning/08_COMPETITION_AI_USAGE_AND_WORKFLOW.md`（已逐項對 repo 查證）。
> 狀態：送件版 v2（2026-07-16），已與 `AI工作流程圖.pptx` 同步並逐頁渲染驗證。

---

## Slide 1：封面

- 標題：**AI 開發工作流程**
- 副標：CrushGameDemo — 一套可複製的 AI 遊戲開發生產線
- 核心命題：**不是 prompt 技巧，而是一套有煞車、有證據、有驗收的 AI 生產線**

> 講者備註：目標不只是完成一款遊戲，而是驗證「一人＋多個 AI」能以工程化流程穩定出貨。

---

## Slide 2：先解決 AI 協作的風險：失憶與漂移

- 問題：只靠聊天上下文協作 AI → 遺忘、誤解、方向漂移
- 解法：**repo 文件是人類與所有 AI 工具的共同介面**

| 文件 | 角色 |
|---|---|
| `AGENTS.md` | AI 行為鐵則（最高準則） |
| `Docs/` 規格＋`Data/*.json` | 單一真實來源，禁止寫死 |
| `OPEN_QUESTIONS.md` | AI 不確定 → 停下提問 |
| `DECISIONS.md` | 人類拍板，append-only 不可竄改 |
| `Codex/` 任務卡 | 一次一張，邊界明確 |
| Git | 每步可追溯，session 間不依賴記憶 |

---

## Slide 3：一張圖看懂：文件如何串起所有 AI

```mermaid
flowchart TD
    A["人類提出遊戲企劃與比賽目標"] --> B["Claude：拆解規格、資料結構與任務卡"]
    B --> C{"規格是否明確？"}

    C -- "否" --> D["OPEN_QUESTIONS：AI 停止猜測並提出選項"]
    D --> E["人類審核、選擇與拍板"]
    E --> F["DECISIONS：追加式保存決策與影響"]
    F --> B

    C -- "是" --> G["Docs 規格 + Data JSON 單一真實來源"]
    G --> H["Codex：一次執行一張 Godot 任務卡"]
    G --> I["GPT Image-2：依 Art Contract 產生靜態素材"]

    I --> I1["Photoshop：去背 / Canvas 統一 / 資產標準化"]
    I1 --> I2["Magnific：角色動畫生成（Idle / Attack / Dead）"]
    I2 --> I3["AE：動態去背，輸出透明 PNG 序列圖"]
    I3 --> I4["Claude：批量製作 Sprite Sheet + JSON"]
    I4 --> J["Manifest：檔名、尺寸、透明與路徑檢查"]
    J --> K["Assets/final 正式素材入口"]
    K --> H

    H --> L["Placeholder fallback：素材缺失仍可完成流程"]
    L --> M["桌面 Godot + Headless + 截圖 + H5 實跑驗收"]

    M --> N{"人類驗收是否通過？"}
    N -- "否" --> O["回饋修正；若涉及方向變更則重新走 Q → D"]
    O --> H
    N -- "是" --> P["Git 保存文件、程式、決策與正式產物"]

    P --> Q["Claude／Codex：Firebase CLI + 瀏覽器部署驗證"]
    Q --> R["可玩的 H5 上線產品"]
```

> 講者備註／PPT 重繪建議：三個泳道上色區分——人類（決策節點 A/E/N）、
> Claude（規劃 B/D/F）、Codex＋美術 AI（執行 G–M）。兩個菱形是人類把關點。

---

## Slide 4：第一道煞車：不確定就停，Q → D 才動工

```mermaid
flowchart LR
    A["AI 遇到模糊或範圍變更"] --> B["寫入 OPEN_QUESTIONS<br/>（附選項與影響分析）"]
    B --> C["人類審核拍板"]
    C --> D["寫入 DECISIONS<br/>（append-only，推翻用新編號）"]
    D --> E["AI 依定案繼續執行"]
```

- 實績：**12 筆提問全數經人類裁示後才動工，0 筆 AI 擅自猜測**
- 案例：Google 登入超出 MVP 範圍 → AI 先提 Q-005 整理方案與風險 → 人類定案 D-015 → 才拆卡實作

---

## Slide 5：第二道煞車：每張任務卡都要閉環

1. 讀 `AGENTS.md`、規格與最新決策
2. 只做當前一張卡，確認「要做／不做／驗收」邊界
3. 數值文案一律讀 `Data/*.json`，不寫死
4. 不明確 → 寫 Q 等人類，不猜
5. 依卡修改程式、場景、資料或素材接點
6. 自動驗證：語法、資料、桌面實跑、截圖、H5、fallback
7. **人類實際遊玩驗收**，提修正或確認通過
8. Git 保存 → 下個 AI session 不依賴前次聊天記憶

- 實績：**27 張卡片全數走完此閉環，各有 Git 紀錄**

---

## Slide 6：小團隊不互等：工程與美術平行合流

```mermaid
flowchart LR
    subgraph 工程線
        A["Placeholder 素材"] --> B["完整可玩閉環"]
    end
    subgraph 美術線
        C["GPT Image-2 靜態素材"] --> D["Photoshop→Magnific→AE→Claude<br/>動畫資產管線"]
        D --> E["Manifest 規格檢查"]
    end
    E --> F["Assets/final 同檔名放入"]
    F --> G["遊戲自動換裝<br/>（缺檔 fallback，不崩潰）"]
    B --> G
```

- 程式只認 `final/` 與 placeholder 兩個入口，正式圖到位即自動生效
- 美術規格衝突不硬改：走 Q-ART 提案 → 人類裁示 → Contract 升版（v1.0 → v1.5）

---

## Slide 7：AI 圖不是成品：8 步變成遊戲資產

**八階段閉環**：風格版／世界觀 → Style Bible／Prompt 規格 → GPT Image-2 靜態生成 →
Photoshop 標準化 → Magnific 角色動畫 → AE 序列圖 → Claude Sprite Sheet＋JSON → GitHub 資產管理

| 工具 | 能力邊界 |
|---|---|
| GPT Image-2 | 靜態素材生成、風格探索 |
| Photoshop | 去背、Resize、Canvas 統一 |
| Magnific | 角色動畫生成（Idle / Attack / Dead） |
| AE | 動態去背、透明序列圖輸出 |
| Claude | 批量 Sprite Sheet、JSON |
| GitHub | 版本管理、素材交付、命名規範 |

- 不讓 AI 直接生 Sprite Sheet（逐幀不一致、比例漂移）——**動畫影片轉序列圖更穩定**
- 設計擔任 AI Art Director：世界觀、一致性、動畫品質由人判斷
- 價值：**AI 放大美術產能，並將 AI 產物轉換成 RD 可直接整合的遊戲資產**

> 講者備註：補足了兩人團隊（設計＋Web RD）沒有動畫師與 Technical Artist 的產能缺口。詳見繳交文件第九章。

---

## Slide 8：人類掌方向與煞車；AI 提供槓桿

| 人類負責 | AI 負責 |
|---|---|
| 核心玩法與產品方向 | 企劃 → 規格、資料結構、任務卡 |
| 審核選項、寫入定案 | 提選項與風險，不代替拍板 |
| 是否啟用新功能／新服務 | 依已確認文件實作 |
| 美術風格與素材採用 | 產出符合合約的素材 |
| 敏感登入與憑證親手操作 | 自動測試、截圖、資料驗證 |
| 實際遊玩最終驗收 | 文件補登與紀錄整理 |

- 一句話：**AI 提供槓桿；人類握住方向盤，也握住煞車**

---

## Slide 9：最後交付的不是 Demo，而是可複製的生產線

- 27 張任務卡 → **完整 H5 遊戲上線**（Google 登入＋Firebase 雲端排行榜）
- 120+ commits、25 筆決策、12 筆 Q 全數裁示——**全程可追溯、可查核**
- 設計＋RD 兩人小團隊、下班時間、約三週完成，流程可複製到下一個專案
- 先玩 30 秒：https://crushgamedemo-bloop.web.app

---

## 備援裁切方案（不上投影片）

1. 簡報時間不足時，Slide 3 只口述主幹：企劃 → 規劃 → Q/D 把關 → 任務卡實作 → 人類驗收 → 上線。
2. 若必須再減頁，優先保留 Slide 4「不確定就停」；它最直接回答 AI 應用與人類責任邊界。
3. 「約三週」口徑來自 2026-06-27 起的 repo 紀錄；現場以「下班時間持續迭代」表述最穩妥。
