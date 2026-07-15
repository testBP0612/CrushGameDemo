# PPT 草稿一：AI 工具使用清單

> 用途：比賽繳交 PPT「AI 工具使用清單」的內容底稿。每個 `## Slide N` 為一頁投影片；
> 「講者備註」不放上投影片，供口頭補充或刪除。
> 事實來源：`Planning/08_COMPETITION_AI_USAGE_AND_WORKFLOW.md`（已逐項對 repo 查證）。
> 狀態：草稿 v1（2026-07-15），待參賽者審核。

---

## Slide 1：封面

- 標題：**AI 工具使用清單**
- 副標：CrushGameDemo — Godot 4.6 手機直式 H5 遊戲
- 一句話定位：**人類決定方向，AI 負責結構化規劃與實作**
- 已上線：https://crushgamedemo-bloop.web.app

> 講者備註：一人利用下班時間開發（2026-06-27 起），全程以 repo 文件為人類與多個 AI 工具的共同介面。

---

## Slide 2：AI 工具總覽（一頁看懂）

| AI 工具 | 模型／版本 | 負責範圍 |
|---|---|---|
| Claude／Claude Code | Sonnet 4.6 / 5.0、Fable 5 | 規劃、規格、資料結構、治理文件、任務卡 |
| OpenAI Codex | GPT-5.5、GPT-5.6-SOL | Godot 實作、測試、驗收協作 |
| GPT Image-2 ＋ Magnific | — | 正式美術管線（底圖生成 → 強化與風格統一） |
| agent-sprite-forge | 開源 Codex skill | UI 貼紙、icon、暫代素材生成 |
| Suno AI | — | BGM 生成 |

- 分工原則：**每個工具只做擅長的事，交接靠 repo 文件，不靠聊天記憶**

---

## Slide 3：Claude／Claude Code — 規劃與治理

- 模型：Sonnet 4.6 → Sonnet 5.0 → Fable 5（依開發期間陸續使用）
- 將企劃轉為 `Docs/` 規格與 `Data/*.json`（數值文案單一真實來源，禁止寫死）
- 整理 `OPEN_QUESTIONS` 選項 → 人類拍板 → 寫入 `DECISIONS`（append-only）
- 規劃 27 張 Codex 任務卡；透過 Firebase CLI＋瀏覽器協助雲端佈建
- **人類把關**：玩法、範圍、雲端權限、登入憑證均由人類決定與親手操作

> 講者備註：代表證據 `Planning/01`、`Docs/DECISIONS.md`、`Firebase/README.md`、任務卡 12/13/17。

---

## Slide 4：OpenAI Codex — Godot 實作工程師

- 模型：GPT-5.5、GPT-5.6-SOL
- 產出：專案骨架、狀態機、下注／戰鬥循環、UI、動畫、特效、音訊服務、排行榜、H5 相容
- 工作紀律：開工先讀 `AGENTS.md` 與當前任務卡；**一次一張卡**；不確定就停下寫 Q，不猜
- 自動驗收：桌面實跑、headless 測試、JSON 驗證、狀態截圖、H5 匯出實測、破壞性測試
- **人類把關**：實際遊玩檢視畫面、手感、文案，完成最終驗收

> 講者備註：代表證據 `AGENTS.md`、`Codex/01`–`27`、`Codex/VALIDATION_CHECKLIST.md`。

---

## Slide 5：美術管線 — GPT Image-2 ＋ Magnific ＋ agent-sprite-forge

- 正式素材：**GPT Image-2 生成底圖 → Magnific 強化、重繪與風格統一**
- 依 Art Contract（鎖版規格書）與 prompt 樣板產出角色、怪物、背景、部分 UI
- agent-sprite-forge（開源 Codex skill，github.com/0x0funky/agent-sprite-forge）：
  早期驗證可行性，後保留產 UI 貼紙、icon、9-slice 皮膚與暫代圖
- 工程不等美術：placeholder 先跑通閉環，正式檔到位即自動換裝
- **人類把關**：美術方向與採用由人類決定；規格衝突走 Q-ART → 決策 → Contract 升版

> 講者備註：Contract 從 v1.0 升到 v1.5，每次升版都有 Q-ART 提案與人類裁示紀錄。

---

## Slide 6：Suno AI — BGM 生成（＋音訊分工）

- BGM 由 Suno AI 生成，依 `Data/audio.json` 資料驅動接入播放
- **SFX 不使用 AI**：取自免費音效素材庫（誠實區分 AI 與非 AI 產出）
- 缺檔設計：任何音檔缺失自動 fallback 靜音，遊戲不崩潰
- **人類把關**：曲風方向與採用與否由參賽者試聽決定

---

## Slide 7：量化成果（截至 2026-07-15，HEAD `c909327`）

| 指標 | 數量 |
|---|---:|
| 開發期間 | 2026-06-27 起（下班時間） |
| Git commits | 122 |
| Codex 任務卡 | 27 張（全數有 Git 紀錄） |
| 人類決策紀錄 | 25 筆（D-001–D-025） |
| AI 主動暫停提問 | 12 筆（全數經人類裁示） |
| GDScript | 36 份、5,552 行（非空白行） |
| JSON 設定檔 | 7 份（單一真實來源） |

- 成品：Google 登入＋Firebase 雲端排行榜的完整 H5 遊戲，已上線

---

## Slide 8：誠信聲明

- 遊戲方向、功能取捨、帳號授權、美術採用、最終驗收——**均由參賽者負責**
- AI 用於：規劃、程式、美術協作、雲端操作、驗證與文件整理
- 本清單依已發生且經參賽者驗證的 repo 紀錄整理，未將未完成工作寫成完成
- 全部證據可於 repo 查核：規格、決策、任務卡、Git 歷史一應俱全

---

## 待參賽者確認的開放項（不上投影片）

1. 比賽有無頁數上限？目前 8 頁，可壓縮成 5–6 頁（合併 5+6、刪 8 併入封底）。
2. 封面是否需要：參賽者姓名／部門／隊名？
3. 遊戲名稱正式對外用「CrushGameDemo」還是另有中文名？
