# 任務 03：自動戰鬥演出與怪物切換

## 目標
把 02 的資料閉環包上**可理解的自動戰鬥演出**：主角連擊 3~5 次、怪物 hurt/death、怪物切換與轉場。仍使用 placeholder。

## 必讀文件
`Docs/05_ANIMATION_SPEC.md`、`Docs/03_STATE_MACHINE.md`、`Docs/06_DATA_SCHEMA.md`（battle_sequences / animation_timing / monsters）。

## 範圍
- `Scripts/actors/hero_actor.gd`、`Scripts/actors/monster_actor.gd`：用 Tween 假動畫表現 idle/attack/hurt/death/walk/enter。
- 怪物血條（HP bar）隨連擊下降，最後一擊歸零（勝利）。
- `BATTLE_ATTACK` 連擊數取 `monsters.json > attack_hits_range`；節奏取 `battle_sequences.json`。
- `ADVANCE_WALK`→`TRANSITION`→下一隻怪物入場，怪物資料依 `monster_for_stage`。
- placeholder 顏色取 `monsters.json > placeholder_color`。

## 不做
- 不接正式美術（08 任務卡）。
- 不做傷害數字以外的特效強化（06 任務卡），但**傷害數字本身**屬本卡。
- 不改 02 的判定/數值邏輯。

## 實作要求
1. 所有演出時長**讀 JSON**，禁止寫死。
2. 連擊與成敗判定時序：連擊播完才判定（`resolve_after_attack`）。
3. 傷害數字由 `Scripts/effects/damage_number.gd` 產生，節奏取 `battle_sequences.damage_number`。
4. 切換怪物時正確更新血條、名稱（`name_key`）、placeholder 顏色。

## 驗收方式
- 一局可看到：主角連擊 → 怪物受擊掉血 → 死亡 → 倍率提升 → 繼續時走路+轉場+新怪物入場。
- 連擊次數落在該怪物 `attack_hits_range` 內。
- 失敗分支可看到怪物反擊 + 主角受擊演出。
- 調整 `battle_sequences.json` 的 `hit_interval` 後節奏明顯改變（證明非寫死）。

## 完成後必須回報
依 `Codex/00_MASTER_PROMPT.md` 格式。
