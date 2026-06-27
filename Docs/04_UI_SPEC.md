# 04 — UI 規格（9:16 直式）

> Codex 必讀 #4。定義畫面版面與節點樹。文案一律取 `Data/ui_text.json`。

## 一、畫布
- 解析度基準：**1080 × 1920（9:16 直式）**。
- Godot 專案設定（由 Codex 在 01 任務卡設定）：
  - `display/window/size/viewport_width = 1080`、`viewport_height = 1920`
  - `display/window/stretch/mode = canvas_items`、`aspect = keep`
- H5 自適應細節見 `07_H5_EXPORT_SPEC.md`。

## 二、版面分區（由上到下）
```
┌───────────────────────────┐
│  [標題列] Logo（小）         │  上 ~12%
│  本局資訊 HUD：              │
│   關卡 x/10 ｜ 倍率 xN       │
│   目前收益 ｜ 金幣餘額       │
├───────────────────────────┤
│                           │
│      中央戰鬥畫面           │  中 ~58%
│   背景                     │
│   主角(左)      怪物(右)     │
│   怪物血條 / 傷害數字       │
│   戰鬥訊息（怪物上方）       │
│                           │
├───────────────────────────┤
│  下方操作區（依狀態切換）：   │  下 ~30%
│   ‑ BETTING：下注面板        │
│       − [金額] ＋ / 開始挑戰 │
│   ‑ REWARD_DECISION：        │
│       [撤退領取 N] [挑戰下一隻]│
│   ‑ SETTLE：結算面板+再來一局 │
└───────────────────────────┘
```

## 三、核心元件（不做的東西別加）
**只需要**：Logo/標題、本局資訊（關卡/倍率/收益/餘額）、中央戰鬥畫面、主角、怪物、怪物血條、
傷害數字、戰鬥訊息、下注面板、開始挑戰/挑戰下一隻、撤退領取、結算面板。

**不要做**：底部 Tab Bar、商店、裝備、成就、設定頁、會員系統、右上常駐寶石/金幣資源列
（餘額顯示在 HUD 即可，非常駐導航）、冒險流程圖 UI。

## 四、建議節點樹（Codex 可微調，責任不變）
```
Main (Node2D)  [Scripts/core/game_controller.gd]
├─ BattleScene (Node2D)
│   ├─ Background (Sprite2D/ColorRect)
│   ├─ Hero (見 Scenes/Actors)
│   ├─ Monster (見 Scenes/Actors)
│   ├─ MonsterHpBar (ProgressBar/TextureProgressBar)
│   └─ DamageNumberLayer (Node2D)
└─ UILayer (CanvasLayer)
    ├─ TitleScreen (Control)
    ├─ Hud (Control)            # 關卡/倍率/收益/餘額
    ├─ BattleMessage (Label)
    ├─ BetPanel (Control)       # − 金額 ＋ / 開始挑戰
    ├─ DecisionPanel (Control)  # 撤退領取 / 挑戰下一隻
    └─ SettlementPanel (Control)
```

## 五、互動狀態
按鈕的顯示/可互動完全依 `03_STATE_MACHINE.md` 的「UI 狀態對應」。
- 下注 −/＋ 受 `min_bet`/`max_bet`/`bet_step` 限制（`Data/game_balance.json`）。
- `balance < bet` 時「開始挑戰」禁用並顯示 `bet_insufficient`。
- 「撤退領取」按鈕文案需帶入即時 `current_payout`（`decision_cashout`）。

## 六、文字
所有顯示字串以 key 取自 `ui_text.json`，`{x}` 變數於執行期代入。**禁止寫死中文字串**。
