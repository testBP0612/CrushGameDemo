# PPT 草稿一：AI 工具使用清單

> 用途：比賽繳交 PPT「AI 工具使用清單」的內容底稿。每個 `## Slide N` 為一頁投影片；
> 「講者備註」不放上投影片，供口頭補充或刪除。
> 事實來源：`Planning/08_COMPETITION_AI_USAGE_AND_WORKFLOW.md`（已逐項對 repo 查證）。
> 狀態：送件版 v2（2026-07-16），已與 `AI工具使用清單.pptx` 同步並逐頁渲染驗證。

---

## Slide 1：封面

- 標題：**AI 工具使用清單**
- 副標：CrushGameDemo — 27 張任務卡跑完的 Godot 4.6 H5 成品
- 一句話定位：**不是 AI 幫我做遊戲，而是把 AI 變成可稽核、可複製的生產線**
- 已上線：https://crushgamedemo-bloop.web.app

> 講者備註：設計＋RD 兩人小團隊利用下班時間開發（2026-06-27 起），全程以 repo 文件為人類與多個 AI 工具的共同介面。

---

## Slide 2：工具不是主角——每個 AI 只做一件事

| AI 工具 | 模型／版本 | 負責範圍 |
|---|---|---|
| Claude／Claude Code | Sonnet 4.6 / 5.0、Fable 5 | 規劃、規格、治理文件、任務卡；Sprite Sheet＋JSON 資產工程 |
| OpenAI Codex | GPT-5.5、GPT-5.6-SOL | Godot 實作、測試、驗收協作 |
| GPT Image-2 | — | 靜態美術素材生成、風格探索 |
| Magnific | — | 角色動畫生成（Idle / Attack / Dead） |
| agent-sprite-forge | 開源 Codex skill | UI 貼紙、icon、暫代素材生成 |
| Suno AI | — | BGM 生成 |

- 分工原則：**每個工具只做擅長的事，交接靠 repo 文件，不靠聊天記憶**

---

## Slide 3：Claude／Claude Code——把模糊需求變成規格

- 模型：Sonnet 4.6 → Sonnet 5.0 → Fable 5（依開發期間陸續使用）
- 將企劃轉為 `Docs/` 規格與 `Data/*.json`（數值文案單一真實來源，禁止寫死）
- 整理 `OPEN_QUESTIONS` 選項 → 人類拍板 → 寫入 `DECISIONS`（append-only）
- 規劃 27 張 Codex 任務卡；透過 Firebase CLI＋瀏覽器協助雲端佈建
- **人類把關**：玩法、範圍、雲端權限、登入憑證均由人類決定與親手操作

> 講者備註：代表證據 `Planning/01`、`Docs/DECISIONS.md`、`Firebase/README.md`、任務卡 12/13/17。

---

## Slide 4：OpenAI Codex——把任務卡變成可玩的 H5

- 模型：GPT-5.5、GPT-5.6-SOL
- 產出：專案骨架、狀態機、下注／戰鬥循環、UI、動畫、特效、音訊服務、排行榜、H5 相容
- 工作紀律：開工先讀 `AGENTS.md` 與當前任務卡；**一次一張卡**；不確定就停下寫 Q，不猜
- 自動驗收：桌面實跑、headless 測試、JSON 驗證、狀態截圖、H5 匯出實測、破壞性測試
- **人類把關**：實際遊玩檢視畫面、手感、文案，完成最終驗收

> 講者備註：代表證據 `AGENTS.md`、`Codex/01`–`27`、`Codex/VALIDATION_CHECKLIST.md`。

---

## Slide 5：美術管線——把 AI 圖變成可直接整合的遊戲資產

**GPT Image-2 靜態生成 → Photoshop 標準化 → Magnific 角色動畫 → AE 序列圖 → Claude 拼 Sprite Sheet＋JSON**

| 工具 | 能力邊界 |
|---|---|
| GPT Image-2 | 靜態素材生成、風格探索 |
| Photoshop（非 AI） | 去背、Resize、Canvas 統一 |
| Magnific | 角色動畫生成（Idle / Attack / Dead） |
| AE（非 AI） | 動態去背、透明 PNG 序列圖 |
| Claude | 批量 Sprite Sheet＋JSON 資產工程 |

- 不讓 AI 直接生 Sprite Sheet：逐幀角色不一致、比例漂移——**改用動畫影片轉序列圖，更穩定**
- agent-sprite-forge（github.com/0x0funky/agent-sprite-forge）：早期驗證＋UI 貼紙與暫代圖
- **人類把關**：設計擔任 AI Art Director，把關風格一致性；規格衝突走 Q-ART → Contract 升版

> 講者備註：Contract 從 v1.0 升到 v1.5，每次升版都有 Q-ART 提案與人類裁示紀錄。詳細八階段見繳交文件第九章。

---

## Slide 6：Suno AI——讓 AI 音樂進得了正式版本

- BGM 由 Suno AI 生成，依 `Data/audio.json` 資料驅動接入播放
- **SFX 不使用 AI**：取自免費音效素材庫（誠實區分 AI 與非 AI 產出）
- 缺檔設計：任何音檔缺失自動 fallback 靜音，遊戲不崩潰
- **人類把關**：曲風方向與採用與否由參賽者試聽決定

---

## Slide 7：不是報告：每個數字都有 repo 證據

| 指標 | 數量 |
|---|---:|
| 開發期間 | 2026-06-27 起（兩人小團隊、下班時間） |
| Git commits | 120+（每一步可追溯） |
| Codex 任務卡 | 27 張（全數完成且有 Git 紀錄） |
| 人類決策紀錄 | 25 筆（D-001–D-025，可查核） |
| AI 主動暫停提問 | 12 筆（全數經人類裁示） |
| GDScript | 36 份、5,500+ 行（可執行成品，不只企劃） |
| JSON 設定檔 | 7 份（數值與文案資料驅動） |

- 可玩證據：Google 登入＋Firebase 排行榜 H5 成品，已上線

---

## Slide 8：可稽核、可重現、可直接玩

- 遊戲方向、功能取捨、帳號授權、美術採用、最終驗收——**均由參賽者負責**
- AI 用於：規劃、程式、美術協作、雲端操作、驗證與文件整理
- 本清單依已發生且經參賽者驗證的 repo 紀錄整理，未將未完成工作寫成完成
- 全部證據可於 repo 查核：規格、決策、任務卡、Git 歷史一應俱全

---

## 備援裁切方案（不上投影片）

1. 現行送件版為 8 頁；若規章另有頁數上限，可合併 5+6、將 8 併入封底，壓成 5–6 頁。
2. 若主辦格式強制要求姓名／部門／隊名，僅需補在封面 eyebrow，不更動敘事結構。
3. 對外名稱全篇統一使用 `CrushGameDemo`，避免臨場出現第二個名稱。
