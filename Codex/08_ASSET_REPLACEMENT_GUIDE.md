# 任務 08：正式美術接入（Asset Replacement）

## 目標
把 `Assets/final/` 中**已符合 manifest** 的正式素材接入 Godot，取代對應 placeholder。缺檔者保持 placeholder。

## 必讀文件
`Assets/ART_ASSET_MANIFEST.md`、`Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md`（v1.0 locked）、`Docs/05_ANIMATION_SPEC.md`。

## 範圍
- 依 manifest 的 `asset_id` / `file_name` / `target_path` / `used_by_scene`，把 `Assets/final/` 的素材接到對應節點。
- 設定 Godot 匯入參數（透明、filter、pixel snap 等依 Contract）。
- 確認接入後演出時序**不變**（時長仍讀 JSON）。

## 不做（鐵則）
- **不得自行生成美術**。
- **不得修改 `Planning/03_ART_CONTRACT_FOR_MAGNIFIC.md`**（要改走 `OPEN_QUESTIONS.md` 的 `Q-ART-XXX`）。
- **不得自行更改檔名 / 路徑規則 / manifest 結構**。
- **不得改核心玩法或數值**。
- **不得依賴 `Assets/generated/`**。

## 實作要求
1. 對每個 manifest 條目：`Assets/final/` 有檔 → 接入正式素材；無檔 → 保留 `fallback_placeholder`，**遊戲不可崩**。
2. 接入後更新 manifest 的 `status` 為 `imported`（這是 manifest 的資料欄位，非 Contract 規格，允許更新）。
3. 若某素材不符合 Contract（尺寸/透明/面向錯誤），**不要硬接**，登記 `Q-ART-XXX` 並維持 placeholder。

## 驗收方式
- `Assets/final/` 齊備的素材正確顯示，缺檔者顯示 placeholder 且無錯誤。
- 動畫時序與接入前一致。
- 移除某個 final 素材後重跑，該角色自動 fallback placeholder、遊戲照常完成一局。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 格式，並列出：哪些 asset_id 已 imported、哪些仍 fallback、有無新增 Q-ART。
