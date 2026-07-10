# 任務 23：設計師 UI 參考圖視覺對齊——邊開遊戲邊調（Codex 執行）

> 人類 2026-07-10 指示：設計師交付四張 UI 圖，放在 `Art/references/GameUI/`。
> 其中 `banner.jpg` 是**要直接使用的標題畫面背景**；其餘三張是**視覺對齊的目標稿**
> （mockup，不是素材——上面的數字/文案是假資料，實際數值一律仍讀 `Data/*.json`）。
>
> **工作方式：邊開遊戲邊視覺對齊。** 你可以自由決定調整順序與手法（改 tscn、改
> ui_skin、換素材、加背景圖都行），但每一步都要在實際跑起來的遊戲畫面上目視比對
> 參考圖（這正是 D-006 要求的目視確認——由你執行即可，不必再等別人看）。
> 對齊到「一眼看過去和參考圖是同一套設計」為止；不必逐 pixel 複製。

## 參考圖 ↔ 遊戲畫面對應表（已核對過程式碼，照這張表做）

| 參考圖 | 對應狀態（`Scripts/core/game_state_machine.gd`） | 對應畫面/節點 | 說明 |
|---|---|---|---|
| `banner.jpg` | `TITLE` | `Scenes/Main.tscn` → `UILayer/TitleScreen`（現在的 `TitleBackground` 是純色 ColorRect） | 標題畫面背景圖，**直接採用**：入 `Assets/final/`、鋪滿為背景。圖上已含 logo「Meow 準快跑!」，現有 TitleLabel 文字與圖重複時自行取捨（可隱藏文字改用圖）。StartButton / LoginButton / BestRecord 疊在圖上，位置自行安排到不擋主視覺 |
| `main.jpg` | `BETTING` | `Scenes/UI/VerticalUi.tscn` → TopBar + Hud + 戰鬥舞台 + `ActionArea/BetPanel` | 下注畫面目標稿：上方玩家頭像+「玩家排行」入口、餘糧列、logo；中段「關卡進度 / 目前倍率 / 目前收益」三欄資訊板；舞台上敵人名牌（骷髏 icon + 名字 + 星級危險度條）；下方「下注內容」面板（左右兩排快捷籌碼 10~5000、中央 −/金額/+、粉紅緞帶標題）；底部藍色大按鈕「喵準開始」 |
| `next.jpg` | 過關後的續戰/撤退抉擇（BetPanel 收起、`ActionArea/DecisionPanel` 顯示的那個階段） | 同上，下半部換 DecisionPanel | 抉擇畫面目標稿：上半部與 main.jpg 完全相同；下半部粉框面板顯示「過關可得 N / 下一關 xN.N 倍 / 危險度 ★ / 若現在撤退約第 N 名」；底部雙按鈕——左「喵準快逃」（撤退，背包 icon）+ 右「喵準開始」（續戰，爪印 icon） |
| `result.jpg` | `CASH_OUT_SETTLE` / `DEFEAT_SETTLE` / `CLEAR_SETTLE` | `ActionArea/SettlementPanel` | 結算畫面目標稿：全螢幕街景背景 + 中央米色圓角面板（深藍描邊、右下角爪印、四角星星點綴）+ 頂上粉紅緞帶標題「結果」。面板內容留白＝照現有結算資訊排入即可 |

註：`main.jpg` 與 `next.jpg` 共用整個上半部（TopBar / 資訊板 / 舞台 / 敵人名牌），
做一次兩邊都受益；兩張圖唯一差異是 ActionArea 內容。

## 必讀

`AGENTS.md`（鐵則全文）、`Docs/DECISIONS.md` 最後幾筆（至少 D-004 fallback、D-006
目視確認、D-012 生成貼紙先例）、`Scripts/ui/ui_skin.gd`（樣式單一入口——能在這裡
統一改的就不要散落各處）、`Scripts/ui/vertical_ui.gd` / `bet_panel.gd`（現有結構）。
注意：`Docs/04_UI_SPEC.md` 座標表已過期，版面以 `VerticalUi.tscn` 實況 + 本卡參考圖為準。

## 素材

- `banner.jpg` 是唯一直接使用的圖，入 `Assets/final/`（格式/命名自行決定）並登記
  `Assets/ART_ASSET_MANIFEST.md`。
- 參考圖裡有、專案裡缺的 UI 素材（例如：敵人名牌的骷髏 icon 與星條、粉紅緞帶標題、
  籌碼按鈕底圖、背包/爪印按鈕 icon、米色面板框、玩家頭像框、獎盃 icon、街景背景等）
  → **自己調用生成貼紙類 skill 生成**（D-012 既有先例），風格對齊參考圖的流浪貓街頭
  cartoon 家族，放 `Assets/final/ui/` 並逐張登記 manifest。
- 每張新素材都要有缺圖 fallback（D-004）：圖不在 → 退回現行純色/文字版，不崩。
- 若認定與 `Art/ART_CONTRACT.md` 鎖定條款衝突 → 停下走 `Q-ART-XXX`，不要硬上。

## 啟動遊戲/截圖驗證方式（前一輪已驗證可用，供參考——你也可用自己的方法）

- **Godot 編輯器**：專案根目錄就是 Godot 專案，開啟後 F5 直跑。本機 Godot 4.6.3
  在 `C:\Users\User\Downloads\Godot_v4.6.3-stable_win64.exe.zip`（解壓即用，
  含 `_console.exe` 版）。
- **無頭截圖 harness**：repo 內 `tmp/ui_capture.gd/.tscn`（gitignored，檔案在磁碟上）——
  `<godot_console.exe> --path E:\CrushGameDemo --resolution 540x960 res://tmp/ui_capture.tscn -- <mode>`，
  mode 有 title/betting/decision/settle/cashout/defeat/reset/leaderboard，適合快速出
  各狀態截圖與參考圖並排比對。
- **H5 預覽迴圈**（D-021 建立）：`.claude/launch.json` 的 `web-preview` 供應
  `export/web/`；改動 → 無頭匯出（`--headless --export-release "Web"`）→ 刷新截圖。
  適合最後的 H5 實機驗收。

## 鐵則提醒（其餘不設限，手法自定）

1. 數值/文案一律讀 `Data/*.json`，禁寫死——參考圖上的數字全是假資料，不要抄進程式。
   新增文案（如緞帶標題）走 `ui_text.json`。
2. 不改遊戲邏輯與狀態機時序；這是純視覺對齊卡。
3. H5 直向版面是正式目標（遊戲已上線），對齊後跑一次 H5 實機確認無跑版。

## 驗收

- 四個畫面各附一張「遊戲實跑截圖 vs 參考圖」對照（TITLE / BETTING / 抉擇 / 結算）。
- 缺圖 fallback 抽驗一例（改壞一張路徑 → 不崩、退回舊樣式）。
- 完整打一輪（下注 → 過關抉擇 → 撤退結算 → 再來一局）確認各面板切換無殘留、無跑版。
- manifest 與 `Docs/06_DATA_SCHEMA.md`（若有新 json 欄位）帳面同步。
- 對照 `VALIDATION_CHECKLIST.md` 慣例補「里程碑 — 任務 23」。

## 完成後必須回報

依 `AGENTS.md` 格式（附四組對照截圖 + 新增素材清單）。
