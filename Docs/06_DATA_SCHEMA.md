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
| `multiplier_curve[]` | array | `{ stage:int, multiplier:float }`，stage 從 1 起。 |
| `success_rate_curve[]` | array | `{ stage:int, success_rate:float(0~1) }`，對應「即將挑戰的關卡」。 |
| `cashout_rules.loss_mode` | string | 失敗損益模式（`lose_current_payout_and_bet`）。 |
| `cashout_rules.cashout_returns` | string | 撤退返還對象（`current_payout`）。 |
| `stage_progression.max_stage` | int | MVP 最多 10 關。 |
| `stage_progression.loop_after_max` | bool | Future 擴充點，MVP 為 false。 |

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

## ui_text.json
| 路徑 | 型別 | 說明 |
|---|---|---|
| `locale` | string | `zh-TW`。 |
| `text.<key>` | string | 文案；`{x}` 為執行期變數。Codex 以 key 取值。 |
| `text.bet_reset_balance` | string | 餘額低於 `min_bet` 時的一鍵重置按鈕文案（D-007）。 |
| `text.profile_mock_display_name` | string | MVP mock profile 顯示名稱。 |

> 缺 key 時的 fallback：建議回傳 `[key]` 字串以利除錯，並寫入 `OPEN_QUESTIONS.md`。

---

## 載入器建議（`Scripts/core/data_loader.gd`）
- 啟動時（`BOOT`）一次載入全部 JSON 至記憶體（`JSON.parse_string`）。
- 提供查表 API：`balance()`, `multiplier_at(stage)`, `success_rate_at(stage)`, `monster_for_stage(stage)`, `text(key, vars)` 等。
- 解析失敗要明確報錯，不可靜默吞掉。
