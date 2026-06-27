# Assets/placeholders/

**Codex 開發用暫代素材**。在正式美術尚未進入 `Assets/final/` 之前，遊戲一律使用本資料夾的暫代資源。

## 內容
- 主角 / 怪物：色塊或簡單圖形（可用 Godot `ColorRect` / `Polygon2D`，或簡單 PNG）。
- 背景：純色或漸層暫代。
- 對應 `Assets/ART_ASSET_MANIFEST.md` 每個 `asset_id` 的 `fallback_placeholder` 欄位。

## 規則
- **每個 manifest 必要素材都必須有對應 placeholder**，確保 `Assets/final/` 缺檔時遊戲仍可跑。
- placeholder 不需要美術品質，只需可辨識（顏色、形狀、相對大小一致）。
- 由 **Codex** 維護；美術同事不需處理本資料夾。
