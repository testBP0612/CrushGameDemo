# 任務 18：怪物序列圖接入（boss1–boss9，Codex 執行）

> **前置**：D-017 已定案（Contract v1.4）。素材已在 `Assets/final/boss/`（未 commit 前先確認在）。
> **第 10 隻依人類裁示暫缺**——stage 10 維持 placeholder，缺檔 fallback 不可阻塞。

## 目標
九隻怪物由 placeholder 色塊換成 idle 動畫（序列圖），對應 stage 1–9；stage 10 與任何缺檔情況維持 placeholder。時序/版面不變。

## 必讀
`Docs/DECISIONS.md`（D-017）、`Art/ART_CONTRACT.md`（v1.4 §七）、`Assets/final/boss/boss1_idle.json`（TexturePacker 格式範例）、`Scripts/actors/hero_actor.gd`（既有 sheet 切格慣例）、`Codex/VALIDATION_CHECKLIST.md` 通用段（**ResourceLoader.exists 鐵則**）。

## 素材規格（已實測）
- `Assets/final/boss/boss<N>_idle.png`（N=1..9）：3072×2304，4×3 grid，768×768/幀，12 幀。
- 同名 `.json`：TexturePacker 格式——`frames{}` 含每幀明確 `frame{x,y,w,h}`；
  `meta.animations["boss<N>_idle"]` 給幀序。**以 JSON 的 frame 座標為準切格**，
  不要自己用 columns/rows 假設（boss7 的 json 較大，幀數可能不同——照 JSON 走就對）。

## 範圍
1. **`Data/monsters.json`**：`monsters[].art_asset_id` 更新為 `boss<N>_idle`（stage 1–9）；
   stage 10 維持現值（placeholder）。只改資料欄位，不改 schema。
2. **`Scripts/actors/monster_actor.gd`**：
   - 依 `art_asset_id` 載入 `Assets/final/boss/<id>.png` + `.json` → 解析 TexturePacker
     `frames` + `meta.animations` → `SpriteFrames`/`AnimatedSprite2D` 播 idle loop。
   - idle fps/時長讀 `animation_timing.json > monster.*`（鐵則 6，不寫死）。
   - **存在性判斷一律 `ResourceLoader.exists()`**（png）；json 為 raw 檔可用 FileAccess。
   - 缺 png/缺 json/解析失敗 → 原 placeholder 色塊，warning 不崩（D-004）。
3. **尺寸與定位**：怪物主體維持 Contract §六 基準（右 ~70%、底部對齊地面線、
   建議主體 ~480 內）——768px 幀需縮放到與現有 placeholder 相近的視覺大小，
   受擊 flash/死亡縮小等既有效果不變。
4. **manifest**：怪物區段更新對映與 `status=imported`（stage 10 標 missing）。
5. **Godot 匯入**：Filter 依風格（非像素 → linear）、Mipmaps off（Contract §八）。

## 不做
- 不做 attack/hurt/death 序列（本批只有 idle；受擊/死亡仍走既有 Tween 效果）。
- 不改戰鬥時序、判定、版面契約。
- 不等第 10 隻；不自行生成補圖。

## 驗收
- 編輯器：stage 1–9 各自顯示對應 idle 動畫、面向左、地面線對齊、與主角不重疊（目視截圖）。
- stage 10：placeholder 色塊如常，流程不受影響。
- 移除任一 boss png 重跑 → 該隻退回 placeholder、不崩（實測一隻）。
- **H5 匯出實機**：怪物動畫正常顯示（通用段鐵則——這批素材大，務必實機確認材質載入與效能）、
  跑完整局無卡頓。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 18」。

## 完成後必須回報
依 `AGENTS.md` 格式（附編輯器 + H5 截圖各至少 2 個 stage、其中一張含 stage 10 placeholder）。
