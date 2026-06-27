# Art Contract（給 Magnific / 美術同事）

> **狀態：v1.0 locked** 🔒
> 本檔是**不可變規格合約**。美術同事與 Codex **都必須遵守**。
> 本檔**只定「接入規格」，不定「美術風格」**。風格（長相、色彩、筆觸…）由美術同事自由決定，見 `ART_DIRECTION_NOTES.md`。
>
> **變更程序（任何人含 AI）**：禁止直接改本檔鎖定項目。先到 `Docs/OPEN_QUESTIONS.md` 開 `Q-ART-XXX`
> → `Docs/DECISIONS.md` 新增決策 → 評估影響 → 人類同意後升 `v1.1`。詳見 `Docs/DECISIONS.md` D-002。

---

## 一、Contract 與 Direction 的邊界
| 不可變（本合約鎖定） | 可變（美術同事決定，見 04） |
|---|---|
| 必要素材清單、檔名、路徑 | 角色長相、怪物造型 |
| 圖片格式、透明背景需求 | 色彩、筆觸、光影 |
| 角色面向、畫面基準位置 | Q版/手繪/像素/童話/暗黑等風格 |
| 背景比例與安全區 | 背景美術風格、Logo 視覺 |
| 單圖 / sprite sheet 接入方式 | UI 視覺質感 |
| Godot 匯入方式、Codex 預期讀取檔名 | — |

> 一句話：**你可以自由探索風格，但交付的檔案必須符合本合約。**

## 二、必要素材清單（MVP）
完整逐項清單見 `Assets/ART_ASSET_MANIFEST.md`（含每項 file_name / path / 是否必要）。摘要：
- **MVP Required**：主角 `hero_idle / hero_attack / hero_hurt / hero_defeat`；怪物 `monster_001_idle`~`monster_005_idle`；背景 `background_battle_001`。
- **Optional**：`game_logo`、`ui_panel_style_reference`、`hero_walk`、怪物 hurt/death、各式特效、6~10 隻怪物。

> Data JSON 已寫 10 隻怪物，但 **MVP 美術只需前 5 隻**；6~10 隻缺圖時遊戲以 placeholder 呈現。

## 三、檔名規則（不可變）
- 全小寫、底線分隔、英數，與 manifest `asset_id` 一致。
- 格式：`<asset_id>.png`，例：`hero_idle.png`、`monster_001_idle.png`、`background_battle_001.png`。
- sprite sheet（若採用）：`<asset_id>_sheet.png` + 同名 `.json`（見第七節）。
- **不得自創檔名 / 路徑**；Codex 依 manifest 檔名讀取，檔名不符即不會被接入。

## 四、路徑規則（不可變）
- 正式素材一律放 `Assets/final/`（唯一正式入口）。
- 候選稿/失敗稿**不進 repo**；可選暫存在本機或 `Assets/generated/`（Codex 不讀）。

## 五、圖片格式與透明背景（不可變）
- 格式：**PNG，32-bit，含 alpha 透明背景**（角色、怪物、特效、Logo）。
- 背景圖 `background_battle_001` 可不透明（全幅底圖）。
- 色彩空間 sRGB；勿內嵌奇特 ICC。
- 邊緣保留乾淨 alpha（避免白邊/雜邊）。

## 六、尺寸、面向、基準位置（不可變）
- 畫布基準 **1080×1920（9:16）**。
- **角色面向**：主角面向**右**（朝怪物）；怪物面向**左**（朝主角）。交付即此面向，不要鏡像由程式處理。
- **建議尺寸**（長邊，透明留白外的主體）：
  - 主角：約 420×420 內。
  - 怪物：約 480×480 內（大型怪可略大，置中於畫布）。
  - 背景：1080×1920 滿版（重要內容置於中央安全區，上下各 12% 可能被 UI 遮蔽）。
  - Logo：寬約 720 內，透明背景。
- **基準位置**：主角錨點在畫面左 ~30%、垂直中線偏下；怪物在右 ~70%。主體底部對齊地面線（約畫面 70% 高度）。

## 七、單圖 / sprite sheet 接入方式（不可變）
- **MVP 預設：單張靜態圖**（idle/attack/hurt 各一張），動態由 Codex 用 Tween 假動畫處理。
- 若要提供逐格動畫，採 **horizontal sprite sheet**：等寬等高格、固定 `frame_count`，附同名 `.json`：
  ```json
  { "asset_id": "hero_attack", "frame_width": 420, "frame_height": 420, "frame_count": 6, "fps": 12 }
  ```
- 不混用：同一 asset_id 要嘛單圖、要嘛 sheet+json，不要兩者並存。

## 八、Godot 匯入注意（不可變）
- 匯入為 `Texture2D`。
- 像素風 → Filter 關閉（nearest）；非像素風 → Filter 開啟（linear）。請在交付時於 manifest `notes` 標明風格屬於哪種，Codex 據此設定。
- Mipmaps 關閉（2D 直接顯示）。
- 勿依賴特定壓縮；保持來源 PNG。

## 九、placeholder → final 替換流程（不可變）
1. 開發期 Codex 用 `Assets/placeholders/`。
2. 美術確認可用 → 依本合約整理 → 放 `Assets/final/`。
3. Codex 在 `Codex/08` 接入 `final/`；缺檔 fallback placeholder，**遊戲不可崩**。
4. `Assets/generated/` 為可選暫存，Codex 不依賴。

## 十、給美術同事的 Magnific 使用建議（指引，非鎖定）
- 可把 `ART_DIRECTION_NOTES.md` 的風格描述丟給 Magnific / AI 產圖。
- Prompt 建議帶：主體、視角（橫向 2D 側視）、面向、**透明背景**、單一角色置中、無地面陰影外溢。
- 產圖後務必：去背確認、裁切到建議尺寸、命名符合第三節、放入 `Assets/final/`。
- 風格自由，但**面向、透明、檔名、尺寸**必須符合本合約。

---
**版本**：v1.0 locked ｜ 變更請走 `Q-ART-XXX` + `DECISIONS.md`。
