# 02 — 人類決策紀錄格式（Human Decision Record）

> 本檔定義決策的**標準格式**，並作為決策**索引**。已定案決策的完整內容寫在 `Docs/DECISIONS.md`。
> 設計目的：讓文件適合**人類審核與拍板**，而非 AI 自說自話。

## 決策紀錄格式（複製此模板）
```md
## D-XXX：<決策標題>
- **問題**：AI 提出的問題 / 待決事項。
- **選項**：A / B / C（各附簡短利弊）。
- **AI 建議**：AI 推薦哪個與理由。
- **人類決策**：人類最終拍板（這一行是權威）。
- **原因**：為什麼這樣決定。
- **影響**：影響哪些檔案、系統、Codex 任務卡、Data JSON、素材。
```

## 流程
```
AI 提問（OPEN_QUESTIONS / 對話）
   → AI 給選項與建議
   → 人類選擇（人類決策）
   → 寫入 Docs/DECISIONS.md（編號 D-XXX）
   → 相關 OPEN_QUESTIONS 標記 ANSWERED 並引用 D-XXX
```

## 規則
- 決策一旦寫入 `DECISIONS.md`，AI 與人類都應遵守。
- 要推翻舊決策 → **新增一筆**標明「取代 D-XXX」，不要直接刪改舊紀錄（保留決策歷史）。
- 涉及 Art Contract 鎖定內容的變更，額外走 Freeze 流程（見 `Planning/01` 與 `DECISIONS.md` D-002）。

## 決策索引（指向 `Docs/DECISIONS.md`）
| 編號 | 標題 | 狀態 |
|---|---|---|
| D-001 | Godot 工程留在 repo root | 定案 |
| D-002 | Art Contract v1.0 Freeze 流程 | 定案 |
| D-003 | 美術風格由美術同事決定，Claude 只定規格 | 定案 |
| D-004 | placeholder-first + art-parallel（輕量素材流程） | 定案 |
| D-005 | DataLoader 改為 autoload 單例 `Data` | 定案 |
| D-006 | 畫面分區改用具體座標契約 + 版面不變量 | 定案 |

> 新決策請同步更新本表與 `Docs/DECISIONS.md`。
