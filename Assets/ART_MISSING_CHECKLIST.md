# 美術素材缺口清單

> 產出日期：2026-07-04｜依據 `Assets/ART_ASSET_MANIFEST.md` 與實際檔案比對。
> 本清單**唯讀參考**，素材交付後請更新 manifest 的 `status` 欄，不要改本檔。

---

## 🔴 MVP Required（缺圖以色塊 placeholder 呈現）

### 主角（Hero）

| 素材 | 路徑 | 規格摘要 |
|---|---|---|
| `hero_attack.png` | `Assets/final/` | PNG32、透明背景、面向右、約 420²；可附 sheet+json |
| `hero_hurt.png` | `Assets/final/` | PNG32、透明背景、面向右、單圖 |
| `hero_defeat.png` | `Assets/final/` | PNG32、透明背景、面向右、單圖 |

### 怪物前 5 隻（Monster）

| 素材 | 路徑 | 怪物設定 | 色塊 fallback |
|---|---|---|---|
| `monster_001_idle.png` | `Assets/final/` | 史萊姆、面向左 | `#7ed957` |
| `monster_002_idle.png` | `Assets/final/` | 水靈獸、面向左 | `#5ec5d4` |
| `monster_003_idle.png` | `Assets/final/` | 魅影蝠、面向左 | `#b083e0` |
| `monster_004_idle.png` | `Assets/final/` | 炎角獸、面向左 | `#e08a5b` |
| `monster_005_idle.png` | `Assets/final/` | 血牙狼、面向左 | `#e05b7a` |

> 怪物規格：PNG32、透明背景、主體約 480² 以內、面向左（朝主角）。

---

## 🟡 Optional（缺圖不阻塞，有 fallback）

| 素材 | 用途 | Fallback |
|---|---|---|
| `game_logo.png` | 標題 Logo（寬 ≤ 720，透明背景） | 顯示文字標題 |
| `monster_006_idle.png` ~ `monster_010_idle.png` | 第 6–10 隻怪物（Data 已定義） | placeholder 色塊 |
| `monster_001_hurt` ~ `monster_005_hurt` | 怪物受擊動畫 | flash/縮放 Tween |
| `monster_001_death` ~ `monster_005_death` | 怪物死亡動畫 | flash/縮放 Tween |
| `battle_slash_effect` | 揮砍特效 | Tween 線條 |
| `hit_flash_effect` | 命中閃光 | 白閃 |
| `cashout_effect` | 撤退特效 | Tween 粒子 |
| `defeat_effect` | 戰敗特效 | Tween 變灰 |

---

## ✅ 已到位（不需補件）

| 類型 | 素材 |
|---|---|
| 主角 | `hero_idle`（含 sprite sheet）、`hero_walk`（含 sheet+json） |
| 背景 | `background_battle_001 / 002 / 003` |
| UI icons | 全 13 組（stage / multiplier / payout / coin / paw / backpack / plus / minus / cat_can / warning / login / cloud / trophy）母檔 + 48px runtime 版 |
| UI 9-slice 皮膚 | 全 8 組（skin_card / panel / btn_primary / btn_secondary / btn_minus / btn_plus / chip / chip_active） |
| 字型 | jf-openhuninn-2.1、Baloo2-Medium |

---

## 交付規範摘要

- 格式：**PNG 32-bit、含 alpha 透明背景**（背景圖可不透明）
- 尺寸：主角約 420²、怪物約 480²、背景 1080×1920
- sprite sheet 硬上限：**單邊 ≤ 4096px**；多格數須用 grid 並附 `.json`
- 放入路徑：`Assets/final/`（子目錄依 manifest 指定）
- 完整規格見 [`Art/ART_CONTRACT.md`](../Art/ART_CONTRACT.md)（v1.3 locked）
