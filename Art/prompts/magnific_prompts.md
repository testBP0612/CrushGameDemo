# Magnific Prompt 樣板（每素材起手）

> 這是**起手樣板**,不是規定。風格由你決定(見 `../ART_DIRECTION_NOTES.md`)。
> 用法:把 `{STYLE}` 換成你定的風格描述(例:「可愛 Q 版手繪、暖色調、粗黑描邊」),其餘**必須保留**以符合 `../ART_CONTRACT.md`:
> 側視(side view)、面向正確、單一主體置中、**透明背景**、無地面陰影外溢。
> 提醒:Magnific 多為「放大/重繪」,通常需要一張底圖;這些字串可用於底圖生成或 Magnific 的風格/結構提示。

## 共用後綴（每個 prompt 都加）
```
2D side-view game sprite, single character centered, full body, clean transparent background,
no ground shadow bleeding outside the silhouette, crisp edges, consistent {STYLE}
```

## 主角 Hero（面向右 / facing right）
- **hero_idle**
  ```
  a heroic young adventurer standing idle, facing right, relaxed confident pose, {STYLE}
  [+ 共用後綴]
  ```
- **hero_attack**
  ```
  the same adventurer mid sword-swing attack, facing right, dynamic forward lunge, {STYLE}
  [+ 共用後綴]
  ```
- **hero_hurt**
  ```
  the same adventurer flinching from a hit, facing right, recoiling backward, pained expression, {STYLE}
  [+ 共用後綴]
  ```
- **hero_defeat**
  ```
  the same adventurer defeated, facing right, kneeling/falling down, dizzy, {STYLE}
  [+ 共用後綴]
  ```

## 怪物 Monsters（面向左 / facing left，對應 monsters.json 名稱）
- **monster_001_idle**：`a cute slime monster (史萊姆), facing left, bouncy idle, {STYLE}`
- **monster_002_idle**：`a water spirit beast (水靈獸), facing left, floating idle, {STYLE}`
- **monster_003_idle**：`a shadow bat creature (魅影蝠), facing left, hovering idle, {STYLE}`
- **monster_004_idle**：`a flame-horned beast (炎角獸), facing left, menacing idle, {STYLE}`
- **monster_005_idle**：`a bloodfang wolf (血牙狼), facing left, fierce idle, {STYLE}`
- (每個都接 共用後綴；6~10 隻 optional,有空再做)

## 背景 Background（不透明、滿版）
- **background_battle_001**
  ```
  a 9:16 vertical battle background, side-view RPG arena/forest/cavern (你選一個), {STYLE},
  central area kept clean and uncluttered (角色會站中間), no characters, no UI,
  1080x1920 full-bleed, depth and atmosphere
  ```
  > 背景**不需要透明**;重要內容放中央安全區(上下各約 12% 可能被 UI 蓋住)。

## (可選) Logo
- **game_logo**：`game logo for "勇者撤離戰", playful RPG title lettering, {STYLE}, transparent background, width <= 720`

---
做完一張就依 `../ARTIST_QUICKSTART.md`:去背 → 裁切 → 命名(= manifest file_name)→ 放 `Assets/final/`。
