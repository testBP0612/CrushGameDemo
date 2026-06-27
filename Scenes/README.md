# Scenes/

Godot 場景（`.tscn`）的存放區。由 **Codex 依任務卡建立**，本階段僅有骨架說明。

## 子資料夾責任

| 路徑 | 責任 |
|---|---|
| `Scenes/Main.tscn` | 遊戲入口場景，掛載 GameController 與狀態機。 |
| `Scenes/BattleScene.tscn` | 中央戰鬥畫面（主角、怪物、血條、傷害數字錨點）。 |
| `Scenes/UI/` | UI 場景：下注面板、本局資訊列、結算面板、按鈕群。 |
| `Scenes/Actors/` | 主角與怪物的角色場景（含 AnimatedSprite2D / placeholder）。 |
| `Scenes/Effects/` | 視覺效果場景：hit flash、傷害數字、撤退/戰敗特效。 |

## 規則

- 場景結構需對應 `Docs/04_UI_SPEC.md` 與 `Docs/03_STATE_MACHINE.md`。
- 美術同事**不要**修改本資料夾（除非有明確任務卡）。
- 素材一律透過 `Assets/placeholders/` 或 `Assets/final/` 載入，缺檔需 fallback。
