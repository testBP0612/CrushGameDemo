# 07 — 比賽素材包（Demo Kit）

> 目的：把 repo 裡散落的「AI 應用證據」整理成評審 30 秒能吸收的簡報素材。
> 本檔取代 `05_PRESENTATION_STORYLINE.md` 的過期部分（05 寫於上線前）。
> 對照評分權重：AI 應用 40% / 完成度 30% / 美術音效 10% / 企劃創意 10% / Demo 5% / 商業 5%。
> 數據統計基準：2026-07-07，commit 34e8548。

## 一句話主軸

> 「我們做的不是一款遊戲，而是一條**能把企劃書變成上線產品的 AI 生產線**——
> 這款已上線的 H5 遊戲（含 Google 登入與雲端排行榜）是它的第一個產物。」

**試玩網址：https://crushgamedemo-bloop.web.app** （手機直式 9:16，開瀏覽器即玩）

---

## 量化效益（簡報數據頁）

| 指標 | 數字 | 備註 |
|---|---:|---|
| 開發時程 | **11 天**（2026-06-27 → 07-07） | 一人 + AI，非全職 |
| 人力 | **1 人** + 3 個 AI 角色 | Claude 規劃治理 / Codex 實作 / Magnific 美術 |
| Commit 數 | 65 | 全程 git 可追溯 |
| 任務卡 | **18 張全數完成** | 每張有範圍/不做清單/驗收方式 |
| 人類決策紀錄 | 18 筆（D-001~018，append-only） | 含 5 次美術合約受控變更（v1.0→v1.5） |
| AI 提問紀錄 | 11 筆，**全數 ANSWERED、零懸置** | AI 不猜、先問的制度證據 |
| 程式碼 | 32 個 GDScript、約 4,300 行 | 分層架構 core/battle/actors/ui/effects/services |
| 正式美術素材 | 133 個檔案 | AI 生成（Magnific），含 9 隻怪物動畫序列圖 |
| 資料驅動 | 7 個 JSON 設定檔 | 數值/文案零寫死（鐵則 6） |
| 上線範圍 | 完整循環 + Google 登入 + 雲端排行榜 | Firebase 佈建由 AI 以 CLI+瀏覽器完成 |

---

## 痛點 → AI 解法 → repo 內證據（對應 40% 評分項）

| # | 開發痛點 | AI 解法 | 評審可翻的證據 |
|---|---|---|---|
| 1 | AI 做遊戲會發散、亂改方向、context rot | **文件治理生產線**：鐵則 + 任務卡 + OPEN_QUESTIONS/DECISIONS 雙帳本，協作走 repo 文件不靠聊天記憶 | `AGENTS.md`、`Docs/OPEN_QUESTIONS.md`（11 問全結案）、`Docs/DECISIONS.md`（18 筆） |
| 2 | 一人團隊沒有美術產能 | **規格鎖版 + AI 生圖平行作業**：Art Contract Freeze、placeholder-first、缺檔 fallback 不崩；規格三次「配合現實交付」受控修訂 | `Art/ART_CONTRACT.md`（v1.5）、`Assets/final/`（133 檔）、D-013/017/018 |
| 3 | 沒有後端人力做登入與記分 | **AI 自己佈建雲端**：Claude 併用 CLI 與瀏覽器完成 Firebase Auth+Firestore+Hosting 佈建與部署（憑證由人類親手輸入） | D-015（明載此為展示亮點）、`Docs/08_ONLINE_SCORE_SPEC.md`、`Firebase/README.md` |
| 4 | 版面驗證要人一直盯 Godot | **AI 自驗截圖 harness**：AI headless 跑遊戲、驅動狀態機、截圖比對 mockup 迭代，等同人工目視驗收（D-006） | `Art/references/ui_target_*.png`（目標） vs 實機截圖；D-006 |
| 5 | 玩法/數值迭代慢 | 數值全 JSON 資料驅動，AI 調平衡不動程式；換一款遊戲只換 `Data/`+`Docs/`+任務卡 | `Data/*.json`（7 檔）、`Docs/BALANCE_NOTES.md`、`Planning/01` |

**人工整合證據**（評審會問「是不是 AI 照抄」）：18 筆 D-決策全是人類拍板；
Codex 曾越權部署被記錄並收斂授權邊界；美術交付與規格不符時走 Q-ART 流程修規格而非硬改素材。

---

## AI 工作流一頁圖（簡報用）

```text
企劃書 (Planning/00)
   ↓
Claude：規格文件 (Docs/01–08) + 資料結構 (Data/*.json)
   ↓                                ↖ 不確定 → OPEN_QUESTIONS (11 問)
Codex 任務卡 (Codex/01–18，一次一張)      人類拍板 → DECISIONS (18 筆)
   ↓
Codex：Godot 實作   ∥   Magnific：美術生圖 (Art Contract 鎖規格)
   ↓                         ↓ 缺檔 fallback，遊戲永不崩
VALIDATION_CHECKLIST 驗收（含 AI 截圖自驗）
   ↓
Claude：Firebase 佈建 (CLI+瀏覽器) → Web 匯出 → 部署上線
   ↓
https://crushgamedemo-bloop.web.app（登入 + 雲端排行榜）
```

---

## 簡報流程（8–10 分鐘，取代 05 的舊版）

1. **痛點（30s）**：一個人 + AI 做遊戲的四個坎——AI 發散、美術產能、沒後端、驗證吃人力。
2. **一句話解法（30s）**：主軸句 + 量化數據頁（11 天/1 人/18 卡/上線）。
3. **工作流走一遍（2m）**：一頁圖 + 現場翻一張任務卡（範圍/不做/驗收）+ Q→D 一條實例
   （建議用 Q-005→D-015：AI 提案 Firebase、人類拍板、AI 自己佈建）。
4. **治理亮點（1.5m）**：OPEN_QUESTIONS 零懸置、DECISIONS append-only、Art Contract
   v1.0→v1.5 五次受控變更——「防 AI 擅改」的制度不是口號是檔案。
5. **實機 Demo（2.5m）**：見下方腳本。
6. **可複製性（1m）**：換遊戲只換 Data/Docs/任務卡，治理骨架不變 → 這就是可推廣到公司其他團隊的 SOP。
7. **商業潛力（30s）**：短局制 H5，適合活動行銷、排行榜挑戰與社群分享；可擴充每日挑戰、
   品牌聯名素材、廣告變現。
8. **收尾（30s）**：「企劃書 → 上線產品，每一步有文件、有邊界、有驗收、有決策紀錄。」

## 實機 Demo 腳本（已含上線功能）

1. 手機或瀏覽器開 **crushgamedemo-bloop.web.app** → Google 登入（展示雲端身分）。
2. 下注 50 → 連勝 2–3 關，倍率跳升、決策畫面顯示「若現在撤退約排第幾」（排行榜回饋層）。
3. 故意續戰到失敗 → 戰敗結算：本次最深進度 + 超過百分比（風險張力 + 數據回饋）。
4. 再來一局 → 連勝後**撤退領取** → 撤退結算 + 排名更新 → 開排行榜面板（真 Firestore 資料）。
5. 重整瀏覽器 → 登入態與雲端紀錄保留（換裝置也在）。
6. 備援：若現場網路死 → 遊戲自動 fallback 本地記分照常可玩（這本身就是亮點：D-015 fallback 契約）。

## 評審 Q&A 備忘

- **AI 會不會亂改方向？** → 鐵則 + 11 筆 Q 全部先問後做 + Art Contract Freeze；翻 git log 給看。
- **AI 產出是不是直接照抄？** → 18 筆人類決策、Codex 越權部署被抓並收斂、美術不符規格走流程。
- **美術怎麼接？** → Contract 鎖規格 + Manifest + 缺檔 fallback；規格服務交付（D-013/017/018）。
- **能換別款遊戲嗎？** → 工作流與遊戲解耦，換 Data/Docs/任務卡即可。
- **後端安全？** → Firestore rules：僅本人可寫、欄位驗證、單調遞增；內部 demo 定位，伺服器驗證列 Future。
- **排行榜人少怎麼辦？** → 說明 mock NPC 機制（D-016 明定 demo 時對評審說明為模擬資料）。

## 待辦（demo 前建議補齊，依投報率排序）

- [ ] 備援影片/截圖：用截圖 harness 錄完整一局（防現場網路/投影意外）。
- [ ] 排行榜預熱：demo 前放幾筆真實紀錄，或確認 mock NPC 顯示狀態。
- [ ] SFX 補檔：9 個事件目前全部靜音（僅 BGM）——音效回饋直接影響「完成度感」，
      有檔即自動接入（`Docs/SFX_TODO.md`），值得 demo 前補最關鍵 3 個（攻擊命中/撤退/戰敗）。
- [ ] BGM 音量人耳確認（文件記錄「audibility unconfirmed」）。
- [ ] 佈建過程截圖彙整一頁（D-015 全程存證的截圖散在工作區，挑 3–4 張進簡報）。
