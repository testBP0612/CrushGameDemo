# 05 — 動畫 / 演出規格（Animation Spec）

> Codex 必讀 #5。定義演出策略。所有時間取自 `Data/animation_timing.json` 與 `Data/battle_sequences.json`。

## 一、Placeholder 策略（MVP 第一階段）
- 角色 / 怪物用 **色塊或簡單圖形**（`ColorRect` / `Polygon2D` / 簡單 PNG），顏色取 `monsters.json > placeholder_color`。
- 「動畫」用 **Tween 假動畫**即可：位移、縮放、旋轉、顏色閃爍，不需要逐格 sprite。
- 之後正式美術（`Assets/final/`）就緒，於 `Codex/08` 任務卡接入 `AnimatedSprite2D` / `Sprite2D`，**不改流程時序**。
- **正式美術不得阻塞遊戲本體**；缺檔一律 fallback placeholder。

## 二、各演出片段
| 動作 | placeholder 表現 | 正式美術表現 | 時長來源 |
|---|---|---|---|
| hero idle | 輕微上下浮動 Tween | idle 圖/動畫 | `animation_timing.hero.idle_loop` |
| hero attack | 向怪物快速突刺再回位 ×N | attack 動畫 ×N | `battle_sequences.attack_sequence` |
| hero hurt | 紅色閃爍 + 後退 | hurt 圖 | `animation_timing.hero.hurt` |
| hero defeat | 倒下（旋轉/變灰） | defeat 圖 | `animation_timing.hero.defeat` |
| hero walk | 左右晃動 + 前進 | walk 動畫 | `animation_timing.hero.walk_loop` |
| monster idle | 輕微縮放呼吸 | idle 圖 | `animation_timing.monster.idle_loop` |
| monster hurt | 白色 hit flash + 震動 | hurt 圖 | `animation_timing.monster.hurt` |
| monster death | 縮小 + 淡出 | death 動畫 | `animation_timing.monster.death` |
| monster enter | 從右側滑入 | enter 動畫 | `animation_timing.monster.enter` |
| 轉場 | 淡入淡出 | 同左 | `animation_timing.transition` |

## 三、連擊節奏（attack_sequence）
- 擊數 N 取 `monsters.json > attack_hits_range` 區間隨機。
- 第一擊延遲 `first_hit_delay`，之後每擊間隔 `hit_interval`。
- 每擊產生一個傷害數字；最後一擊使怪物 HP 條歸零（勝利分支）。
- 連擊播完才進行成敗判定（見 `02_SYSTEM_SPEC.md`）。

## 四、傷害數字（damage_number）
- 從怪物位置上升 `rise_distance`，`rise_duration` 後 `fade_duration` 淡出。
- 多擊以 `stagger_between_hits` 錯開，避免重疊。
- 由 `Scripts/effects/` 管理，建議物件池（MVP 可簡單 new/free）。

## 五、手感（在 `Codex/06` 強化，非第一階段）
hit flash、輕微畫面震動、按鈕回饋、撤退/戰敗特效。第一階段先求流程可讀。
