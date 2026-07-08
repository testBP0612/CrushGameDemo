# 任務 22：撤退/通關「大贏插頁」演出——金色數字慶祝畫面（Codex 執行）

> 人類 2026-07-08 指示（附博奕遊戲參考圖：深色底 + 木牌標題「恭賀贏得」+ 特大金色
> 數字 + 「點擊任意處繼續」）。目的：撤退當下的「賺到了」回饋感——目前撤退直接落到
> 結算面板，情緒是「報表」不是「中獎」。
>
> **定位：純視覺插頁**。狀態機時序零改動——進入 CASH_OUT_SETTLE / CLEAR_SETTLE 時
> 在最上層蓋一張慶祝畫面，點擊（或保底逾時）後收掉，露出底下既有結算面板。
> 戰敗（DEFEAT_SETTLE）不出現。

## 目標

1. 撤退成功 / 完美通關進結算的瞬間，全螢幕插頁：半透明暗底 + 標題（「恭賀贏得」）
   + **特大金色貼紙數字**顯示本局收益（count-up 跳數）+ 底部「點擊任意處繼續」提示。
2. 點擊任意處 → 插頁淡出，露出既有結算面板（結算面板本身不改）。
3. **金色數字為生成貼紙素材**（0–9 + 逗號），用 agent-sprite-forge 類 skill 生成
   （D-012「UI icon 貼紙」類別的既有先例）；缺圖 fallback 大號 Label 文字，不崩。

## 必讀

`AGENTS.md`（鐵則 6/8/9）、`Docs/DECISIONS.md` D-012（生成貼紙先例）+ D-004（fallback
鐵則）、`Scripts/core/game_controller.gd`（`_play_presentation_for_state`、
`_on_settled`——插頁掛載點）、`Scripts/effects/coin_burst.gd`（程式建 CanvasLayer 的
慣例，任務 19）、`Scripts/effects/payout_count_up.gd`（跳數慣例）、
`Scripts/ui/ui_skin.gd`（樣式單一入口）。

## 素材（先生成，再寫程式）

用生成貼紙 skill 產出，放 `Assets/final/ui/windigits/`，逐一登記 manifest：

| 檔名 | 內容 | 規格 |
|---|---|---|
| `digit_0.png` … `digit_9.png` | 數字 0–9 | 金色立體貼紙字，厚描邊＋高光，透明背景 PNG32，高 ~192px，等高不等寬 |
| `digit_comma.png` | 千分位逗號 | 同風格，約半寬 |

- 風格對齊參考：金黃漸層＋橘紅描邊（見任務卡附註的參考圖意象），但**輪廓厚度與
  貼紙感沿用本專案現有 UI 家族**（流浪貓街頭 cartoon），不要照搬水族風。
- 十一張風格必須一致（同一批生成、同 prompt 系列）。
- 若認定與 Art Contract v1.5 鎖定條款衝突 → 停下走 `Q-ART-XXX`，不要硬上。

## 範圍

### 1. `Scripts/effects/win_banner.gd`（新檔）
- 比照 coin_burst：程式建 `CanvasLayer`（layer 高於 coin_burst 的 2，例如 3），
  不動任何 `.tscn`。
- 結構：全螢幕擋點擊的暗底（`ColorRect` 半透明深藍，非純黑）→ 中央 VBox：
  標題 Label（`win_banner_title`，UiSkin 現有 settle 標題風格或 ribbon）→
  **DigitStrip**（見下）→ 底部提示 Label（`win_banner_continue`，小字呼吸閃爍）。
- **DigitStrip**：HBox 動態組 TextureRect——把整數格式化為千分位字串，逐字元對映
  `digit_<n>.png` / `digit_comma.png`；任何一張缺圖 → 整條退回大號 Label
  （`ResourceLoader.exists` 判斷，D-004）。
- 演出序：暗底淡入 `appear` → 數字從 0 count-up 至實際收益（`count_up` 秒，數字組
  每 tick 重組；沿用 PayoutCountUp 的 tween 手法）→ 完成後輕微 scale 呼吸。
- 關閉：任意點擊（`min_show` 秒內忽略，防誤觸秒關）或 `auto_dismiss` 逾時保底
  → 淡出 `queue_free()`，發 `dismissed` signal。**任何路徑都必須能關**——插頁卡死
  = 遊戲卡死，保底逾時不可省。

### 2. `Scripts/core/game_controller.gd`
- `_on_settled(result)`：`result` 為 `cash_out` 或 `clear` 且結算金額 > 0 時建立
  WinBanner（fire-and-forget，不 await、不擋 `_update_view`）；`defeat` 不建。
- 金額來源：`_last_settlement_payout`（既有欄位，defeat 才是損失值，cash_out/clear
  即實得收益）。
- 插頁與結算面板同時存在（插頁在上層蓋住）；點掉插頁即見結算——**不得**延遲結算
  面板本身的顯示邏輯。

### 3. `Data/animation_timing.json` 新增 `effects.win_banner`
```json
"win_banner": {
  "appear": 0.25,
  "count_up": 0.90,
  "min_show": 0.80,
  "auto_dismiss": 6.0,
  "fade_out": 0.20,
  "digit_height": 150.0
}
```
（數值可依手感微調，欄位齊備、程式全讀 json，鐵則 6。）

### 4. `Data/ui_text.json` 新增 key（初稿，人類保留改句權）
```json
"win_banner_title": "恭賀贏得",
"win_banner_continue": "點擊任意處繼續"
```

### 5. 帳面
- `Assets/ART_ASSET_MANIFEST.md`：windigits 十一張入 UI 素材段（status/fallback 註記）。
- `Docs/06_DATA_SCHEMA.md`：`effects.win_banner` 欄位一行。

## 不做
- 不改狀態機/結算金額/`settled` 訊號時序；不改結算面板；不動任何 `.tscn`。
- 戰敗不出插頁；收益 0（理論上不會發生於 cash_out/clear）不出插頁。
- 不加新 SFX 事件（`cashout`/`clear` 既有事件已在插頁出現同刻觸發，音檔到位自然同步）。
- 不做粒子/煙火（爆金幣已有；要加光效用 Tween 呼吸即可）。

## 實作要求
1. 數值讀 `animation_timing.json > effects.win_banner`、文案讀 `ui_text.json`，禁寫死。
2. 缺任何數字圖 → DigitStrip 整條退 Label 文字版，演出照常（D-004）。
3. 點擊吞沒不可穿透到底下結算按鈕（`mouse_filter = STOP`）；插頁存活期間「再來一局」
   不可被誤觸。
4. 連續多局不殘留節點（dismiss 即 `queue_free`；新局進 BETTING 時若仍在畫面上強制清）。

## 驗收
- 撤退：插頁先出（暗底+標題+金色數字跳數+提示）→ 點擊 → 露出結算面板；戰敗直接結算
  無插頁；通關也有插頁。
- 數字正確含千分位（驗 3 位數 / 5 位數 / 含 0 的金額各一例，截圖）。
- `min_show` 內點擊無效；不點擊 `auto_dismiss` 秒後自動收掉（實測）。
- 暫時改壞一張 digit 圖路徑 → 文字版 fallback 照常演出、可關閉、不崩。
- 改 json 的 `count_up`/`auto_dismiss` → 行為即變。
- 連打三局（撤退×2 + 戰敗×1）無節點殘留、無誤觸結算按鈕。
- **H5 實機**：插頁全螢幕覆蓋正確、觸控可關、無掉幀（附截圖）。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 22」。

## 完成後必須回報
依 `AGENTS.md` 格式（附截圖：插頁全貌、數字特寫、fallback 文字版、結算面板露出後）。
