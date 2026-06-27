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
> 任何想改動 `Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md` 鎖定內容者（含 AI），**禁止直接改檔**，先在此登記：
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
- 狀態：OPEN
- 提出者：Claude
- 背景：當 `balance < min_bet`，玩家無法下注，需要復原機制（`02_SYSTEM_SPEC.md` 第四節）。
- 選項：
  - A. 一鍵把餘額重置為 `starting_balance`（最簡單，適合 demo）。
  - B. 給予固定救濟金幣。
  - C. 顯示「遊戲結束」並只能重整。
- AI 建議：A（內部試玩 demo 體驗最順）。
- 影響範圍：`05_SETTLEMENT_AND_LOCAL_SCORE` 任務卡、`ui_text.json`、`LocalScoreService`。
- 人類回答：_（待填）_

### Q-002：是否需要音效 / 音樂
- 狀態：OPEN
- 提出者：Claude
- 背景：MVP 是否納入基本音效會影響任務卡範圍與 H5 音訊解鎖處理（`07`）。
- AI 建議：MVP 先不做音效，列 Future；若有空檔在 `06_FEEL_AND_EFFECTS` 末段加無關鍵成敗的點擊音。
- 影響範圍：`06_FEEL_AND_EFFECTS`、`07_H5_EXPORT_SPEC`。
- 人類回答：_（待填）_
