# ART ASSET MANIFEST — 素材合約清單

> Godot / Codex / 美術同事三方的**素材合約**。檔名與路徑**以本清單為準**。
> 接入規格細節見 `Art/ART_CONTRACT.md`（v1.0 locked）。
> 變更必要素材清單/檔名/路徑屬 Contract 鎖定項目 → 走 `Docs/OPEN_QUESTIONS.md` 的 `Q-ART-XXX` + `Docs/DECISIONS.md`。
> 例外：`status` 欄是**資料欄位**，Codex 接入後可更新為 `imported`，不算改 Contract。

## 欄位說明
| 欄位 | 說明 |
|---|---|
| `asset_id` | 唯一代號，等於檔名主體。 |
| `file_name` | `<asset_id>.png`（sheet 另附 `_sheet.png`+`.json`）。 |
| `target_path` | 放置路徑（正式素材一律 `Assets/final/`）。 |
| `required` | `required`（MVP 必要）/ `optional`。 |
| `image_format` | 圖片格式（PNG 32-bit）。 |
| `transparent` | 是否需透明背景。 |
| `orientation` | 面向（主角 right、怪物 left、其他 n/a）。 |
| `purpose` | 用途。 |
| `used_by_scene` | 被哪個場景使用。 |
| `fallback_placeholder` | 缺檔時 Codex 必用的暫代。 |
| `status` | `planned → final → imported`。 |
| `owner` | 負責人。 |
| `notes` | 備註（含像素/非像素風格，供 Codex 設 Filter）。 |

---

## MVP Required

### 主角（Hero）
| asset_id | file_name | target_path | required | format | transparent | orientation | purpose | used_by_scene | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| hero_idle | hero_idle.png | Assets/final/ | required | PNG32 | yes | right | 主角待機 | Scenes/Actors | 色塊(藍) | planned | 美術 | 約420² |
| hero_attack | hero_attack.png | Assets/final/ | required | PNG32 | yes | right | 主角攻擊 | Scenes/Actors | 色塊(藍) | planned | 美術 | 單圖或sheet |
| hero_hurt | hero_hurt.png | Assets/final/ | required | PNG32 | yes | right | 主角受擊 | Scenes/Actors | 色塊閃紅 | planned | 美術 | — |
| hero_defeat | hero_defeat.png | Assets/final/ | required | PNG32 | yes | right | 主角戰敗 | Scenes/Actors | 色塊變灰 | planned | 美術 | — |

### 怪物（前 5 隻必要）
| asset_id | file_name | target_path | required | format | transparent | orientation | purpose | used_by_scene | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| monster_001_idle | monster_001_idle.png | Assets/final/ | required | PNG32 | yes | left | 第1關怪物 | Scenes/Actors | 色塊#7ed957 | planned | 美術 | 史萊姆 |
| monster_002_idle | monster_002_idle.png | Assets/final/ | required | PNG32 | yes | left | 第2關怪物 | Scenes/Actors | 色塊#5ec5d4 | planned | 美術 | 水靈獸 |
| monster_003_idle | monster_003_idle.png | Assets/final/ | required | PNG32 | yes | left | 第3關怪物 | Scenes/Actors | 色塊#b083e0 | planned | 美術 | 魅影蝠 |
| monster_004_idle | monster_004_idle.png | Assets/final/ | required | PNG32 | yes | left | 第4關怪物 | Scenes/Actors | 色塊#e08a5b | planned | 美術 | 炎角獸 |
| monster_005_idle | monster_005_idle.png | Assets/final/ | required | PNG32 | yes | left | 第5關怪物 | Scenes/Actors | 色塊#e05b7a | planned | 美術 | 血牙狼 |

### 背景
| asset_id | file_name | target_path | required | format | transparent | orientation | purpose | used_by_scene | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| background_battle_001 | background_battle_001.png | Assets/final/ | required | PNG24/32 | no | n/a | 戰鬥背景 | Scenes/BattleScene | 漸層底色 | planned | 美術 | 1080×1920滿版 |

### UI（可選但建議）
| asset_id | file_name | target_path | required | format | transparent | orientation | purpose | used_by_scene | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| game_logo | game_logo.png | Assets/final/ | optional | PNG32 | yes | n/a | 標題 Logo | Scenes/UI/TitleScreen | 文字標題 | planned | 美術 | 寬≤720 |
| ui_panel_style_reference | ui_panel_style_reference.png | Assets/final/ | optional | PNG32 | yes | n/a | UI 風格參考 | （參考用） | 內建樣式 | planned | 美術 | 非必接入 |

---

## Optional / Future（缺圖以 placeholder 呈現，不阻塞 MVP）
| asset_id | required | fallback | notes |
|---|---|---|---|
| hero_walk | optional | idle 位移 | 行走動畫 |
| monster_001_hurt / monster_001_death | optional | flash/縮放 | 受擊/死亡 |
| monster_002_hurt / monster_002_death | optional | flash/縮放 | 受擊/死亡 |
| battle_slash_effect | optional | Tween 線條 | 揮砍特效 |
| hit_flash_effect | optional | 白閃 | 命中閃光 |
| cashout_effect | optional | Tween 粒子 | 撤退特效 |
| defeat_effect | optional | Tween 變灰 | 戰敗特效 |
| monster_006_idle ~ monster_010_idle | optional | placeholder_color | 6~10 隻怪物（Data 已有，美術後補） |

> 提醒：`Data/monsters.json` 已定義 10 隻怪物（含 `art_asset_id`）。MVP 美術只鎖前 5 隻 idle；
> 其餘 optional，缺圖時 Codex 以 `placeholder_color` 色塊呈現，遊戲照常可玩。
