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
| hero_idle | hero_idle.png | Assets/final/ | required | PNG32 | yes | right | 主角待機 | Scenes/Actors | 色塊(藍) | imported | 美術 | 約420² |
| hero_attack | hero_attack.png + hero_attack.json | Assets/final/ | required | PNG32 | yes | right | 主角攻擊 | Scenes/Actors | 色塊(藍) | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| hero_hurt | hero_hurt.png | Assets/final/ | required | PNG32 | yes | right | 主角受擊 | Scenes/Actors | 色塊閃紅 | planned | 美術 | — |
| hero_defeat | hero_defeat_sheet.png + hero_defeat_sheet.json | Assets/final/ | required | PNG32 | yes | right | 主角戰敗 | Scenes/Actors | 色塊變灰/旋轉 | imported | 美術 | grid 序列圖（768×768、4×3、12 幀）；non-loop，播放時長依 animation_timing.json hero.defeat |

### 怪物（stage 1–9 idle 序列圖；stage 10 placeholder）
| asset_id | file_name | target_path | required | format | transparent | orientation | purpose | used_by_scene | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| boss1_idle | boss1_idle.png + boss1_idle.json | Assets/final/boss/ | required | PNG32 | yes | left | 第1關怪物 idle 序列圖 | Scenes/Actors | 色塊#7ed957 | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss2_idle | boss2_idle.png + boss2_idle.json | Assets/final/boss/ | required | PNG32 | yes | left | 第2關怪物 idle 序列圖 | Scenes/Actors | 色塊#5ec5d4 | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss3_idle | boss3_idle.png + boss3_idle.json | Assets/final/boss/ | required | PNG32 | yes | left | 第3關怪物 idle 序列圖 | Scenes/Actors | 色塊#b083e0 | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss4_idle | boss4_idle.png + boss4_idle.json | Assets/final/boss/ | required | PNG32 | yes | left | 第4關怪物 idle 序列圖 | Scenes/Actors | 色塊#e08a5b | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss5_idle | boss5_idle.png + boss5_idle.json | Assets/final/boss/ | required | PNG32 | yes | left | 第5關怪物 idle 序列圖 | Scenes/Actors | 色塊#e05b7a | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss6_idle | boss6_idle.png + boss6_idle.json | Assets/final/boss/ | optional | PNG32 | yes | left | 第6關怪物 idle 序列圖 | Scenes/Actors | 色塊#d4c45e | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss7_idle | boss7_idle.png + boss7_idle.json | Assets/final/boss/ | optional | PNG32 | yes | left | 第7關怪物 idle 序列圖 | Scenes/Actors | 色塊#5e7ad4 | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss8_idle | boss8_idle.png + boss8_idle.json | Assets/final/boss/ | optional | PNG32 | yes | left | 第8關怪物 idle 序列圖 | Scenes/Actors | 色塊#9b5ed4 | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| boss9_idle | boss9_idle.png + boss9_idle.json | Assets/final/boss/ | optional | PNG32 | yes | left | 第9關怪物 idle 序列圖 | Scenes/Actors | 色塊#d45e9b | imported | 美術 | TexturePacker JSON；非像素、linear、mipmaps off |
| monster_010_idle | monster_010_idle.png | Assets/final/ | optional | PNG32 | yes | left | 第10關怪物 | Scenes/Actors | 色塊#c0392b | missing | 美術 | 依 D-017 暫缺，維持 placeholder |

### 背景（分區，依 game_balance.json `background_zones` 選用）
| asset_id | file_name | target_path | required | format | transparent | orientation | purpose | used_by_scene | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| background_battle_001 | background_battle_001.jpg | Assets/final/ | required | JPG（D-018；亦容 PNG） | no | n/a | 戰鬥背景 zone 1（關 1–3） | Scenes/BattleScene | 漸層底色 | imported | 美術 | 1080×1920滿版（jpg 新版已達標；舊 png 941×1672 暫留庫作備份） |
| background_battle_002 | background_battle_002.jpg | Assets/final/ | recommended | JPG（D-018；亦容 PNG） | no | n/a | 戰鬥背景 zone 2（關 4–6） | Scenes/BattleScene | 退 background_battle_001→漸層 | imported | 美術 | 1080×1920滿版（舊 png 暫留庫） |
| background_battle_003 | background_battle_003.jpg | Assets/final/ | recommended | JPG（D-018；亦容 PNG） | no | n/a | 戰鬥背景 zone 3（關 7–10） | Scenes/BattleScene | 退 background_battle_001→漸層 | imported | 美術 | 1080×1920滿版（舊 png 暫留庫） |

> 背景採**分區**：實際用哪張由 `Data/game_balance.json > background_zones` 決定（可擴充更多 zone/背景）。
> `001` 為 required（至少要有一張）；`002/003` recommended，缺檔時依 `fallback_background_id` 退 `001`、再退漸層 placeholder，遊戲不崩。命名沿用 `background_battle_<序號>` 可繼續往後加（004…）。
> 副檔名：程式依 `.jpg` → `.jpeg` → `.png` 優先序解析（D-018，Contract v1.5）；同 id 多格式並存時以 jpg 為準。

### UI（可選但建議）
| asset_id | file_name | target_path | required | format | transparent | orientation | purpose | used_by_scene | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| game_logo | logo.png | Assets/final/ | optional | PNG32 | yes | n/a | 標題 Logo（標題畫面大圖＋遊戲中右上角） | TitleScreen / VerticalUi TopBar | 文字標題 | imported | 美術 | 實際交付檔名 logo.png（Meow 準快跑！）；2026-07-12 換新版 |
| title_banner | title_banner.jpg | Assets/final/ | optional | JPG | no | n/a | 標題畫面滿版主視覺（設計師交付） | TitleScreen | background_battle_001＋文字標題 | imported | 設計師 | 1080×1920；圖上已含遊戲 Logo，直接顯示、不再疊獨立 Logo |
| intermission_background | intermission.jpg | Assets/final/ | optional | JPG | no | n/a | 挑戰失敗／撤退成功結算畫面滿版背景 | BattlePresenter | 當前關卡背景 | imported | 設計師 | DEFEAT_SETTLE／CASH_OUT_SETTLE 顯示；下一局進入 BETTING 時強制恢復關卡背景 |
| ui_panel_style_reference | ui_panel_style_reference.png | Assets/final/ | optional | PNG32 | yes | n/a | UI 風格參考 | （參考用） | 內建樣式 | planned | 美術 | 非必接入 |

### mockup 整圖素材（對齊 ui_mockup_battle，UiSkin art_texture/apply_art_button 載入）
| asset_id | file_name | target_path | required | transparent | purpose | fallback | status | notes |
|---|---|---|---|---|---|---|---|---|
| ui_board | board.png | Assets/final/ui/ | optional | yes | HUD 單板木質看板（取代三欄卡） | 程式 StyleBoxFlat 底板 | imported | 欄位標題由 Label 疊字（ui_text.json） |
| ui_title_start | title_start.png | Assets/final/ui/ | optional | yes | 標題畫面「喵準開始 Go!」整圖按鈕 | 程式 primary 文字按鈕 | imported | 642×160，標題畫面 1:1 顯示 |
| ui_login_google | login_google.png | Assets/final/ui/ | optional | yes | 標題畫面 Google 登入整圖按鈕 | 程式 login 文字按鈕 | imported | 642×161；登入後切回可辨識的登出文字狀態 |
| ui_best_record_bg | best_record_bg.png | Assets/final/ui/ | optional | yes | 標題畫面最佳紀錄背板 | 程式 ribbon 樣式 | imported | 644×83，動態紀錄文案仍讀 ui_text.json |
| ui_bet_ribbon | bet_info.png | Assets/final/ui/ | optional | yes | 下注面板「下注內容」緞帶（含烤字） | 粉紅程式緞帶＋文字 | retired | **已停用並刪檔（2026-07-12）**：緞帶與文字已烙進新版 skin_panel.png |
| ui_bet_context | bet_context.png | Assets/final/ui/ | optional | yes | 下注面板中央貓糧插圖 | 自動隱藏 | imported | 裝飾用 |
| ui_btn_next | next.png | Assets/final/ui/ | optional | yes | 決策畫面續戰按鈕（烤字「繼續挑戰」，2026-07-12 換版） | 文字按鈕 primary 樣式 | imported | 烤字素材，改字需重出圖 |
| ui_btn_start | start.png | Assets/final/ui/ | optional | yes | 下注畫面滿寬確認鈕（烤字「喵準開始」，990×162） | 文字按鈕 primary 樣式 | imported | 設計師交付（2026-07-12）；烤字素材，改字需重出圖 |
| ui_risk_state | risk_state.png | Assets/final/ui/ | optional | yes | 戰場危險度底條（骷髏徽章+深色橫條，447×112，1:1 顯示） | 程式深色藥丸+「危險度」字+爪印 | imported | 設計師交付（2026-07-12）；金星數量由程式疊 risk_star |
| ui_risk_star | risk_star.png | Assets/final/ui/ | optional | yes | 危險度金星（35×35，顯示 42px） | 同上（缺任一張整組退回舊樣式） | imported | 設計師交付（2026-07-12）；只排亮星不畫暗星（照設計稿） |
| ui_result_card | result_card.png | Assets/final/ui/ | optional | yes | 結算結果卡（含烙字「結果」緞帶，906×905） | 程式 settle 樣式+文字緞帶 | imported | 設計師交付（2026-07-12）；敗局依設計稿填入中央版面，改緞帶字需重出圖 |
| ui_ranking_btn_sm | ranking_btn_sm.png | Assets/final/ui/ | optional | yes | 結算畫面「排行榜」鈕（烙字，428×130，原尺寸顯示） | 文字連結/膠囊樣式 | imported | 設計師交付（2026-07-12）；烙字素材，改字需重出圖 |
| ui_btn_replay | replay.png | Assets/final/ui/ | optional | yes | 新版結算畫面「再來一局」鈕（烙字，428×130，原尺寸顯示） | 文字按鈕 primary 樣式 | imported | 設計師交付（2026-07-14）；與 ranking_btn_sm 並排 |
| ui_btn_retreat | retreat.png | Assets/final/ui/ | optional | yes | 撤退大按鈕（烤字「喵準快逃」） | 文字按鈕 secondary 樣式 | imported | 烤字素材，改字需重出圖 |
| ui_ranking_btn | ranking_btn.png | Assets/final/ui/ | optional | yes | 左上角排行榜入口（頭像＋獎盃＋烤字「玩家排行」整圖鈕） | 文字獎盃膠囊 trophy_pill | imported | 設計師交付（2026-07-12）；478×294，取代舊 ProfileFrame＋排行膠囊 |
| ui_money_card | money_card.png | Assets/final/ui/ | optional | yes | 左上角餘額卡（含零食 icon 底圖，數字程式疊字） | 資源膠囊＋「金幣 N」文案 | imported | 設計師交付（2026-07-12）；430×80，數字千分位由程式格式化 |

---

## UI 素材（icon 貼紙 + 9-slice 皮膚；見 DECISIONS D-012〔含 Round 3 修訂〕/ Q-ART-002）
> **HUD 卡 + 下方操作區（下注面板/按鈕/籌碼）**：採**生成的 9-slice 貼圖皮膚** `skin_*.png`（`StyleBoxTexture`），缺圖 fallback 程式 StyleBoxFlat。
> **其餘元件**（ProfileFrame、SettlementPanel、ribbon 等）仍由程式 StyleBoxFlat 畫。
> **icon 貼紙**：實際載入 `runtime/<id>_48.png`（48px）；`Assets/final/ui/<id>.png` 為全尺寸母檔。
> 風格：流浪貓街頭、美式 cartoon、厚描邊、貼紙感（同背景家族）。

### 9-slice 皮膚（Round 3，apply_panel/apply_button 載入）
| asset_id | file_name | 對應 style | status | notes |
|---|---|---|---|---|
| skin_card | skin_card.png | card（HUD 三欄卡） | imported | 奶白+深藍厚描邊 |
| skin_panel | skin_panel.png | large（下注面板） | imported | 奶白+深藍厚描邊；2026-07-12 換版含烙字「下注內容」緞帶（取代 bet_info.png），改字需重出圖；缺檔退 flat 時由 TitleLabel 文字補標題 |
| skin_btn_primary | skin_btn_primary.png | primary（開始挑戰/挑戰下一隻） | imported | 青綠 |
| skin_btn_secondary | skin_btn_secondary.png | secondary（撤退領取） | imported | 暖橘/桃 |
| skin_btn_minus | skin_btn_minus.png | step_decrease（−） | imported | 桃紅 |
| skin_btn_plus | skin_btn_plus.png | step_increase（＋） | imported | 青綠 |
| skin_chip | skin_chip.png | chip（籌碼） | imported | 青藍邊 |
| skin_chip_active | skin_chip_active.png | chip_selected（選中籌碼） | imported | 高亮 |

### icon 貼紙

| asset_id | file_name（母檔 / 載入） | target_path | required | transparent | status | notes |
|---|---|---|---|---|---|---|
| icon_stage | icon_stage.png / runtime/icon_stage_48.png | Assets/final/ui/ | imported | yes | imported | HUD 關卡（貓爪） |
| icon_multiplier | icon_multiplier.png / runtime/…_48.png | Assets/final/ui/ | imported | yes | imported | HUD 倍率（閃電） |
| icon_payout | icon_payout.png / runtime/…_48.png | Assets/final/ui/ | imported | yes | imported | HUD 收益（魚乾/魚骨） |
| icon_coin | icon_coin.png / runtime/…_48.png | Assets/final/ui/ | imported | yes | imported | 金幣膠囊 |
| icon_paw | icon_paw.png / runtime/…_48.png | Assets/final/ui/ | imported | yes | imported | 開始挑戰/挑戰下一隻 |
| icon_backpack | icon_backpack.png / runtime/…_48.png | Assets/final/ui/ | imported | yes | imported | 撤退領取 |
| icon_plus / icon_minus | icon_plus.png / icon_minus.png（+ _48） | Assets/final/ui/ | imported | yes | imported | 下注 ＋／− |
| icon_cat_can | icon_cat_can.png / runtime/…_48.png | Assets/final/ui/ | imported | yes | imported | 結算裝飾 |
| icon_warning | icon_warning.png / runtime/…_48.png | Assets/final/ui/ | imported | yes | imported | 金幣不足提示 |
| icon_login | icon_login.png / runtime/icon_login_48.png | Assets/final/ui/ | imported | yes | imported | Google 登入/登出按鈕貼紙（貓項圈鈴鐺） |
| icon_cloud | icon_cloud.png / runtime/icon_cloud_48.png | Assets/final/ui/ | imported | yes | imported | 已登入/雲端同步標記（雲朵魚滴） |
| icon_trophy | icon_trophy.png / runtime/icon_trophy_48.png | Assets/final/ui/ | imported | yes | imported | 排行榜入口與面板貼紙 |

> 註：D-012 初版曾移除舊框貼圖（`ui_panel_*`、`ui_btn_*`、`ui_chip*`，當時改純程式畫）；Round 3 改用上表全新的 `skin_*` 9-slice 皮膚取得插畫質感（見 D-012 修訂）。

### win banner 金色數字貼紙（任務 22）

| asset_id | file_name | target_path | required | transparent | status | notes |
|---|---|---|---|---|---|---|
| windigit_0 | digit_0.png | Assets/final/ui/windigits/ | optional | yes | imported | 大贏插頁 DigitStrip；缺任一張整條 fallback Label |
| windigit_1 | digit_1.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_2 | digit_2.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_3 | digit_3.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_4 | digit_4.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_5 | digit_5.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_6 | digit_6.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_7 | digit_7.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_8 | digit_8.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_9 | digit_9.png | Assets/final/ui/windigits/ | optional | yes | imported | 同上 |
| windigit_comma | digit_comma.png | Assets/final/ui/windigits/ | optional | yes | imported | 千分位逗號；同風格貼紙 |

### 虎爺事件素材（任務 24 / D-022；接通模式同 title_banner——設計師 git push 同檔名即自動換裝）

| asset_id | file_name | target_path | required | transparent | fallback | status | owner | notes |
|---|---|---|---|---|---|---|---|---|
| huye | huye.png | Assets/final/ | required（事件用） | yes | Codex 生成暫代→程式金色圓placeholder | generated | 設計師 | 虎爺本體貼紙，PNG32，建議 700–900px 見方（需壓得住 ~480px 怪物），居高臨下壓下或盤坐雲上，流浪貓街頭 cartoon 家族；Codex 先以生成貼紙暫代（status 標 generated），設計師覆蓋同檔名後改 final |
| huye_event_banner | huye_event_banner.png | Assets/final/ | required（事件插頁） | no | 僅顯示繼續提示 | imported | 設計師 | 任務 24 完整事件 banner；程式滿版寬、依原圖比例顯示並垂直置中，取代舊程式組字插頁 |

---

## Optional / Future（缺圖以 placeholder 呈現，不阻塞 MVP）
| asset_id | required | fallback | notes |
|---|---|---|---|
| hero_walk | wired | idle 位移 | 行走動畫；`hero_walk_sheet.png`（4x3=3072x2304，符合 Contract v1.3）+ `hero_walk_sheet.json`（同 hero_idle schema：frame_width/height/columns/rows/frame_count/fps）已接入 `HeroActor.play_walk()`；缺圖時 fallback 回 idle 位移 tween |
| monster_001_hurt / monster_001_death | optional | flash/縮放 | 受擊/死亡 |
| monster_002_hurt / monster_002_death | optional | flash/縮放 | 受擊/死亡 |
| battle_slash_effect | optional | Tween 線條 | 揮砍特效 |
| hit_flash_effect | optional | 白閃 | 命中閃光 |
| cashout_effect | optional | Tween 粒子 | 撤退特效 |
| defeat_effect | optional | Tween 變灰 | 戰敗特效 |
| monster_010_idle | optional | placeholder_color | 第 10 隻怪物依 D-017 暫缺，維持 placeholder；未來補檔後再接入 |

> 提醒：`Data/monsters.json` 已定義 10 隻怪物（含 `art_asset_id`）。stage 1–9 對映 `bossN_idle`；
> stage 10 與任何缺圖情境以 `placeholder_color` 色塊呈現，遊戲照常可玩。
