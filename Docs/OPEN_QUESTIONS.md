# OPEN QUESTIONS — AI 不確定事項清單

> 這是 **AI（Codex / Claude）遇到不明確處的唯一登記簿**。
> 規則：Codex **不得自行猜測核心玩法或擅自決定方向**。遇到不確定，**寫進這裡**，等人類回答，
> 回答定案後再把結論搬到 `DECISIONS.md`，並標記此問題為已解決。

## 使用格式
```md
### Q-XXX：<簡短標題>
- 狀態：OPEN / ANSWERED
- 提出者：Codex / Claude / 人類
- 背景：為什麼會卡住（哪張任務卡、哪個檔案）
- 選項：A / B / C（附簡短利弊）
- AI 建議：<建議哪個>
- 影響範圍：哪些 Codex 任務卡 / Data JSON / 場景 / 素材
- 人類回答：<人類填，定案後寫入 DECISIONS.md 編號>
```

## 美術規格變更專用格式（Art Contract 已 `v1.0 locked` 時必用）
> 任何想改動 `Art/ART_CONTRACT.md` 鎖定內容者（含 AI），**禁止直接改檔**，先在此登記：
```md
### Q-ART-XXX：<想改的合約項目>
- 狀態：OPEN
- 想改什麼：必要素材清單 / 檔名 / 路徑 / 透明背景 / 角色面向 / 背景比例 / 匯入方式 / 預期檔名…
- 原因：
- 影響：哪些 Codex 任務卡（特別是 08）、哪些 manifest 條目、哪些 Data JSON
- 建議新版本號：v1.1
- 人類裁示：<同意升版 / 駁回 / 修改後同意>
```

---

## 現有問題

### Q-001：餘額不足時的處理
- 狀態：ANSWERED → 見 DECISIONS D-007
- 提出者：Claude
- 背景：當 `balance < min_bet`，玩家無法下注，需要復原機制（`02_SYSTEM_SPEC.md` 第四節）。
- 選項：
  - A. 一鍵把餘額重置為 `starting_balance`（最簡單，適合 demo）。
  - B. 給予固定救濟金幣。
  - C. 顯示「遊戲結束」並只能重整。
- AI 建議：A（內部試玩 demo 體驗最順）。
- 影響範圍：`05_SETTLEMENT_AND_LOCAL_SCORE` 任務卡、`ui_text.json`、`LocalScoreService`。
- 人類回答：A

### Q-002：是否需要音效 / 音樂
- 狀態：ANSWERED → 見 DECISIONS D-008
- 提出者：Claude
- 背景：MVP 是否納入基本音效會影響任務卡範圍與 H5 音訊解鎖處理（`07`）。
- AI 建議：MVP 先不做音效，列 Future；若有空檔在 `06_FEEL_AND_EFFECTS` 末段加無關鍵成敗的點擊音。
- 影響範圍：`06_FEEL_AND_EFFECTS`、`07_H5_EXPORT_SPEC`。
- 人類回答：先列出音效空缺就好，把接口預留

### Q-003：缺少正式 UI mockup 圖檔
- 狀態：ANSWERED（採 A：已補上 `Art/references/ui_mockup_battle.png`）
- 提出者：Codex
- 背景：任務 04 指定必讀 `Art/references/ui_mockup_battle.png`，但工作區 `Planning/` 內沒有該檔案；本次只能依 `Docs/04_UI_SPEC.md` 的座標契約與版面不變量實作。
- 選項：
  - A. 補上 `Art/references/ui_mockup_battle.png`，後續 UI 微調以該圖為目標。
  - B. 將 `Docs/04_UI_SPEC.md` 改為不再引用該圖片，只保留座標契約。
- AI 建議：A（保留視覺目標，方便 task 04/後續 review 精準對齊）。
- 影響範圍：`04_H5_VERTICAL_UI`、後續 UI/美術檢查。
- 人類回答：已填入

### Q-ART-001：背景改為分區（新增 background_battle_002/003）
- 狀態：ANSWERED（核准 → 見 DECISIONS D-011，Contract 升 v1.1）
- 想改什麼：必要素材清單（新增 recommended 背景 `background_battle_002`、`background_battle_003`）+ 新增資料驅動的背景選用機制。
- 原因：讓整局有「越闖越深」的分區層次（關 1–3 / 4–6 / 7–10 各一張背景）。
- 影響：`Art/ART_CONTRACT.md`（v1.0→v1.1）、`Assets/ART_ASSET_MANIFEST.md`（+2 背景）、`Data/game_balance.json`（+`background_zones`）、`Docs/06`、`Codex/08`（接入需依 zone 選圖 + fallback）。
- 建議新版本號：v1.1
- 人類裁示：同意升版（規格沿用 001：1080×1920、不透明；缺檔 fallback 不阻塞）。
