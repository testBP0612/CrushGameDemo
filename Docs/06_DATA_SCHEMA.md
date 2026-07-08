# 06 — 資料結構（Data Schema）

> Codex 必讀 #6。`Data/*.json` 是所有數值/文案的**單一真實來源**。
> Codex **禁止**把這些數值或字串寫死在 script，一律由載入器讀取。
> 本檔欄位若需變更，走 `OPEN_QUESTIONS.md` → `DECISIONS.md` 流程。

通用：每個檔皆有 `schema_version`，以底線開頭的 `_comment` / `_*` 欄位為註解，程式應忽略。

---

## game_balance.json
| 路徑 | 型別 | 說明 |
|---|---|---|
| `currency.id` | string | 貨幣代號（`coins`）。 |
| `currency.starting_balance` | int | 初始餘額。 |
| `currency.min_bet` / `max_bet` / `bet_step` / `default_bet` | int | 下注上下限、步進、預設值。 |
| `currency.quick_bet_options` | int[] | 下注面板快捷籌碼金額（資料驅動，禁止程式硬湊）。每個值必須落在 `[min_bet, max_bet]` 內。 |
| `payout.rounding` | string | `floor`（收益取整方式）。 |
| `payout.base_multiplier_at_stage_0` | float | stage 0 的倍率（1.0）。 |
| `multiplier_curve[]` | array | `{ stage:int, multiplier:float }`，stage 從 1 起。D-019 起為「基準曲線」：`multiplier_random.enabled` 時作為每局隨機盤的輸入。 |
| `multiplier_random.enabled` | bool | D-019 每局隨機倍率盤開關；false = 完全走 `multiplier_curve` 原值（回歸路徑）。 |
| `multiplier_random.jitter_pct_stage_1` / `jitter_pct_stage_max` | float | 抖動幅度，由第 1 關線性放大至最終關（如 0.10 → 0.30）。 |
| `multiplier_random.min_growth_ratio` | float | 單調遞增保底：本關 ≥ 前關 × 此值。 |
| `multiplier_random.round_decimals` | int | 盤面倍率四捨小數位數。 |
| `success_rate_curve[]` | array | `{ stage:int, success_rate:float(0~1) }`，對應「即將挑戰的關卡」。D-019：不隨倍率盤連動。 |
| `danger_display.max_level` | int | D-019 危險度分級數（取代血條顯示）；≤0 時整組隱藏。 |
| `danger_display.levels[]` | array | `{ min_success_rate:float, level:int }`，依即將挑戰關卡的 success_rate 由上而下取第一個符合者。 |
| `cashout_rules.loss_mode` | string | 失敗損益模式（`lose_current_payout_and_bet`）。 |
| `cashout_rules.cashout_returns` | string | 撤退返還對象（`current_payout`）。 |
| `stage_progression.max_stage` | int | MVP 最多 10 關。 |
| `stage_progression.loop_after_max` | bool | Future 擴充點，MVP 為 false。 |
| `background_zones.default_background_id` | string | 預設背景（如 BETTING/未涵蓋關卡）。 |
| `background_zones.fallback_background_id` | string | 某 zone 背景缺檔時優先退用的背景；仍缺則退漸層 placeholder。 |
| `background_zones.zones[]` | array | `{ from_stage:int, to_stage:int, background_id:string }`，依「即將挑戰的關卡」選背景。可擴充更多 zone。 |

## monsters.json
| 路徑 | 型別 | 說明 |
|---|---|---|
| `monsters[].id` | string | 怪物代號。 |
| `monsters[].stage` | int | 對應關卡（1~10）。 |
| `monsters[].name_key` | string | 名稱字串 key（查 `ui_text.json`）。 |
| `monsters[].display_hp` | int | 演出用血量（非真實傷害數值）。 |
| `monsters[].attack_hits_range` | [int,int] | 主角對其連擊次數區間。 |
| `monsters[].placeholder_color` | string(hex) | placeholder 色塊顏色。 |
| `monsters[].art_asset_id` | string | 對應 `ART_ASSET_MANIFEST` 的 asset_id。 |
| `monsters[].required_for_mvp` | bool | 是否為 MVP 必要美術（前 5 隻 true）。 |

## battle_sequences.json
| 路徑 | 型別 | 說明 |
|---|---|---|
| `attack_sequence.hit_interval` | float(s) | 每擊間隔。 |
| `attack_sequence.first_hit_delay` | float(s) | 第一擊延遲。 |
| `attack_sequence.hero_attack_frame_count` | int | 主角攻擊序列圖幀數；正式動畫可載入時以實際幀數優先。 |
| `attack_sequence.hero_attack_contact_frame` | int | 主角攻擊伸手打到的幀序，用於對齊前衝到位時間。 |
| `attack_sequence.hero_attack_recover_frame` | int | 主角攻擊收手幀序，用於對齊後退開始時間。 |
| `attack_sequence.hero_strike_charge_lerp_weight` | float | 主角攻擊蓄力時相對目標方向的位移比例，可為負值表示微後壓。 |
| `attack_sequence.hero_strike_lerp_weight` | float(0~1) | 主角攻擊時往怪物方向前衝的距離比例。 |
| `attack_sequence.damage_per_hit_ratio` | float | 每擊扣血比例（演出用）。 |
| `result_resolution.resolve_after_attack` | bool | 連擊後才判定。 |
| `result_resolution.win_branch.*` / `lose_branch.*` | float(s) | 勝/敗分支各演出時長。 |
| `advance_sequence.*` | float(s) | walk / 轉場 / 下隻入場時長。 |
| `damage_number.*` | float/int | 傷害數字上升距離與時間。 |

## animation_timing.json
| 路徑 | 型別 | 說明 |
|---|---|---|
| `hero.*` / `monster.*` | float(s) | 各角色動畫片段時長。 |
| `transition.*` | float(s) | 轉場時間。 |
| `ui.*` | float(s) | UI 動效時間。 |
| `effects.coin_burst.*` | 混合 | 任務 19 爆金幣參數：`count_base:int` + `count_per_multiplier:float`（金幣數 = base + 該次擊殺後倍率 × 此值）、`count_max:int`（上限）、噴發/滯空/吸入各時長與物理值（`burst_duration`/`launch_speed`/`spread_degrees`/`gravity`/`hover_time`/`fly_duration`/`fly_stagger`/`spawn_stagger`/`scale_min~max`/`arrive_fade`，float）、`canvas_layer:int`、`max_hold:float(s)`（跳數暫扣保底，時間到數字照跳）。 |
| `effects.win_banner.*` | float(s/px) | 任務 22 大贏插頁參數：`appear` / `count_up` / `min_show` / `auto_dismiss` / `fade_out` 為秒，`digit_height` 為貼紙數字顯示高度(px)。 |

## ui_text.json
| 路徑 | 型別 | 說明 |
|---|---|---|
| `locale` | string | `zh-TW`。 |
| `text.<key>` | string | 文案；`{x}` 為執行期變數。Codex 以 key 取值。 |
| `text.bet_reset_balance` | string | 餘額低於 `min_bet` 時的一鍵重置按鈕文案（D-007）。 |
| `text.profile_mock_display_name` | string | MVP mock profile 顯示名稱。 |

> 缺 key 時的 fallback：建議回傳 `[key]` 字串以利除錯，並寫入 `OPEN_QUESTIONS.md`。

## audio.json（D-014 新增）
| 路徑 | 型別 | 說明 |
|---|---|---|
| `bgm.file` | string | BGM 檔名（相對 `Assets/final/audio/`，如 `bgm_main.mp3`）。 |
| `bgm.loop` | bool | BGM 是否循環。 |
| `bgm.volume_db` | float | BGM 音量（dB）。 |
| `sfx_volume_db` | float | SFX 統一音量（dB）。 |
| `sfx_events.<event_id>` | string | 事件→SFX 檔名映射。**只列已有音檔的事件**；未列出的 event_id 一律靜音略過。event_id 全集見 `Docs/SFX_TODO.md`，不得擅增。 |

> 容錯（D-014）：檔案缺失/整檔缺失 → warning + 靜音，遊戲不可壞；即回到 D-008 的無聲狀態。

## leaderboard_mock.json（D-016 Phase 1 新增；D-020 修訂）
| 路徑 | 型別 | 說明 |
|---|---|---|
| `keep_in_production` | bool | D-020：true 時正式版（Firebase）也在 client 端把 NPC 併入榜面與排名計算（保底避免空榜）；false = 回 D-016 原行為（純雲端）。不寫任何假資料進 Firestore。 |
| `entries[]` | array | Mock 排行榜 NPC 名單，明示為模擬資料。 |
| `entries[].display_name` | string | NPC 顯示名稱。 |
| `entries[].best_payout` | int | NPC 歷史最佳單局收益，用於 `best_payout` 排名。 |

> `MockLeaderboardService` 會把玩家本人（`ScoreService.get_best_payout()` + profile display name）併入同一排序；NPC 不得寫死在 `.gd`。

---

## 載入器建議（`Scripts/core/data_loader.gd`）
- 啟動時（`BOOT`）一次載入全部 JSON 至記憶體（`JSON.parse_string`）。
- 提供查表 API：`balance()`, `multiplier_at(stage)`, `success_rate_at(stage)`, `monster_for_stage(stage)`, `text(key, vars)` 等。
- 解析失敗要明確報錯，不可靜默吞掉。
