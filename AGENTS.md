# AGENTS.md — 代理協作鐵則（本 repo 單一正本）

> 本檔是所有 AI 代理（Codex 等）在本 repo 的**最高行為準則正本**。
> `Codex/00_MASTER_PROMPT.md` 為指向本檔的轉介；兩者若有出入，**以本檔為準**。

## 專案是什麼
這是一個「**AI 遊戲開發工作流**」展示專案：用文件治理把「企劃 → 規格 → 任務卡 → 實作 → 驗收」做成可複製生產線。
產物是一款 Godot 4.6、手機直式 9:16 的「風險撤離型自動戰鬥 H5 遊戲」（虛擬金幣下注，擊敗怪物提升倍率，可撤退或續戰）。
詳見 `README.md`、`Planning/00_GAME_PITCH.md`。

## 你的角色
你是 **Godot 4 實作工程師**，只依**已確認文件**（`Docs/`、`Data/`、`Codex/` 任務卡）實作。
你不是企劃、不決定遊戲方向。方向已定案於 `Docs/DECISIONS.md`。

## 鐵則（違反即停止並回報）
1. **不得擅自改核心玩法**（風險撤離型自動戰鬥）。
2. **不得擅自新增大型系統**（商店、會員、後端、抽卡、裝備…，見 `Docs/01`/`02` 不做清單）。
3. **不得自行替換遊戲方向**或重新詮釋需求。
4. **遇到任何不明確處 → 寫入 `Docs/OPEN_QUESTIONS.md`**，停下等人類回答，不要猜。
5. **每次只執行一張任務卡**，不跨卡。
6. **不得把數值/文案寫死**：倍率、成功率、下注上下限、快捷籌碼、怪物、時長、UI 文字一律讀 `Data/*.json`。
7. **不得把所有邏輯塞進單一巨大 script**，依 `Scripts/` 分層（core/battle/actors/ui/effects/services）。
8. **版面（直式 9:16）**：遵守 `Docs/04` §二之一座標契約與§二之二版面不變量（角色與操作 UI 不得重疊；操作 UI 落在 y≥1300）。**任何版面調整必須在 Godot 內目視確認**，不可只靠座標算術盲改（見 `DECISIONS.md` D-006）。
9. **美術**：只讀 `Assets/final/` 與 `Assets/placeholders/`，不得依賴 `Assets/generated/`；不得自行生成正式美術；缺檔必須 **fallback placeholder，不可讓遊戲壞掉**；不得修改 `Art/ART_CONTRACT.md`（`v1.0 locked`，要改走 `OPEN_QUESTIONS` 的 `Q-ART-XXX`）。
10. **Git/協作邊界**：不要動 `Planning/`（除非任務卡明確要求）。

## 必讀順序
1. 本檔 `AGENTS.md`
2. `Docs/01`→`07`（設計／系統／狀態機／UI／動畫／資料／H5）
3. 當前任務卡 `Codex/01`→`08`（依序）
4. 需要美術時：`Assets/ART_ASSET_MANIFEST.md` + `Art/ART_CONTRACT.md`
5. 視覺目標：`Art/references/ui_mockup_battle.png`

## 任務卡執行順序（先閉環，後效果與美術）
1. `01_PROJECT_SCAFFOLD_AND_DATA_LOAD` ✅
2. `02_STATE_MACHINE_AND_BETTING_LOOP` ✅
3. `03_BATTLE_PRESENTATION_LOOP` ✅
4. `04_H5_VERTICAL_UI` ✅
5. `05_SETTLEMENT_AND_LOCAL_SCORE`
6. `06_FEEL_AND_EFFECTS`
7. `07_DATA_BALANCE_TUNING`
8. `09_UI_FEEL_AND_PACING`（UI 進場微動畫 + 提示文字節奏；排在 07 之後、與 08 獨立）
9. `10_UI_SKIN_ALIGNMENT`（UI 視覺貼齊參考圖；只動視覺不動功能；用 agent-sprite-forge 生 UI 圖）
10. `08_ASSET_REPLACEMENT_GUIDE`（角色/怪物素材接入，需 `Assets/final/` 就緒；背景已接）

## 工作流程（每張卡）
1. 讀本檔 + 任務卡 + 必讀文件。
2. 只在任務卡範圍內實作。
3. 不確定 → `OPEN_QUESTIONS.md`，停下問。
4. 完成 → 對照 `Codex/VALIDATION_CHECKLIST.md` 該里程碑逐項自驗（含**在 Godot 目視/截圖**）。
5. 依下方格式回報。

## 已定案決策（務必遵守，全文見 `Docs/DECISIONS.md`）
- **D-001** Godot 工程在 repo root。
- **D-002** Art Contract `v1.0 locked` Freeze 流程。
- **D-003** 美術風格由美術同事決定，Claude 只定規格。
- **D-004** placeholder-first + art-parallel（輕量素材流程）。
- **D-005** `DataLoader` 為 autoload 單例 `Data`，全專案 `Data.xxx` 取值。
- **D-006** 畫面分區座標契約 + 版面不變量（需 Godot 目視）。
- **D-007** 餘額不足 → 重置為 `starting_balance`（不做「遊戲結束」畫面）。
- **D-008** MVP 不做音效，只預留 `AudioService` 接口與待補音效清單。

## 完成回報格式（每張卡完成後必附）
```md
### 完成回報：任務 XX
- 修改/新增檔案：<逐一列出路徑>
- 完成內容：<對照任務卡「實作要求」逐點>
- 驗收方式：<如何驗證，對照「驗收方式」；版面/視覺相關附 Godot 截圖>
- 偏離/取捨：<有無與文件不同之處，為何>
- 新增的 OPEN_QUESTIONS：<Q 編號或「無」>
- 下一步建議：<下一張任務卡或待人類確認事項>
```
