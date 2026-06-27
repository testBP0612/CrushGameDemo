# 任務 07：數值調校

## 目標
在遊戲可玩後，純粹透過 `Data/*.json` 調校手感與難度曲線，不改程式邏輯。輸出一份簡短調校筆記。

## 必讀文件
`Docs/02_SYSTEM_SPEC.md`、`Docs/06_DATA_SCHEMA.md`、`Data/game_balance.json`、`Data/monsters.json`、`Data/battle_sequences.json`。

## 範圍
- 調整 `multiplier_curve`、`success_rate_curve` 讓「撤退 vs 繼續」張力明顯（期望值隨關卡微降，鼓勵見好就收但保留拚一把誘因）。
- 調整怪物 `display_hp`、`attack_hits_range`、`name_key` 對應。
- 調整 `battle_sequences.json` 節奏讓單局約數十秒。
- 視需要微調 `ui_text.json` 文案語氣（繁中）。

## 不做
- **不改任何 `.gd` 程式邏輯**（純資料調整）。
- 不新增系統 / 怪物美術需求（6~10 隻仍 optional）。
- 不改 schema 結構（要改 schema 走 OPEN_QUESTIONS）。

## 實作要求
1. 只動 `Data/*.json` 與必要的調校筆記檔。
2. 保持 JSON 合法（可被解析）。
3. 在 `Codex/` 或 `Docs/` 留一份簡短 `balance_notes`（調了什麼、為什麼、觀察到的手感）。

## 驗收方式
- 連玩數局，難度曲線與節奏符合預期（不會太快結束或無腦繼續）。
- 改 JSON 後不需改程式即生效。
- JSON 全部通過解析驗證。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 格式。
