# 任務 10：UI 視覺貼齊參考圖（只動視覺，不動功能）

## 目標
在**完全不改功能與結構**的前提下，把現有 Godot UI 的「視覺分量」往參考圖 `Art/references/ui_mockup_battle.png` 靠近：
更大更粗的數字、更整合的 HUD、貼紙感卡框、按鈕加 icon、間距與位置更講究。
讓實機畫面和參考圖「像同一款遊戲」。

## 必讀
`AGENTS.md`、`Docs/04_UI_SPEC.md`（§二之一座標契約、§二之二版面不變量）、`Art/ART_SPEC_SHEET.md`（UI 尺寸表）、
`Art/references/ui_mockup_battle.png`（**對齊目標**）、現有 `Scenes/UI/VerticalUi.tscn` 與 `Scripts/ui/*`。
產生 UI 圖時用 Codex skill `$generate2dsprite`（若未安裝則停下回報；風格同下方「視覺風格」）。

## 範圍（只做這些）
1. **HUD 三欄（關卡/倍率/收益）**：數字放大加粗、加上小 icon、欄位分隔更清楚、整體更像參考圖的整合資訊條。
2. **金幣膠囊（HUD 右下）**：icon + 數字字級與配色貼齊。
3. **下注面板**：標題做成貼紙橫幅感、下注數字放大、−／＋ 與快捷籌碼的貼紙感與間距貼齊。
4. **決策雙按鈕（撤退領取 / 挑戰下一隻）**：加 icon、字級/配色/圓角貼齊參考圖（撤退=暖色、挑戰=青綠）。
5. **結算面板**：標題/數字字級、卡框貼紙感、再來一局按鈕貼齊。
6. 需要的 **UI 圖像素材**（卡框 9-slice、按鈕底 9-slice、icon 貼紙）依下方清單生成。
7. 為達上述，可微調**字體大小**與**元件位置/間距/內距**（見下方規格）。

## 明確不做（邊界，違反即失敗）
- **不改功能 / 狀態流程 / 數值 / 互動邏輯**（Scripts 只動視覺套用，不動 game logic）。
- **不照抄參考圖的結構差異**：
  - 下注**維持單一項目**（−／金額／＋ + 快捷籌碼），**不要**改成參考圖的「貓罐頭＋貓零食兩欄」。
  - **不要**新增參考圖才有的副標文字列、不新增節點種類/數量去改變版面骨架（可加 icon 與換底圖，但不重排資訊架構）。
- **不碰標題 Logo**（`game_logo` 不在本次）與**不碰怪物**（怪物 sprite、名牌、HP 條維持現狀）。
- 文字一律 Godot Label 顯示，**圖像不內嵌中文字**。
- 不改 `Art/ART_CONTRACT.md`（locked）；新增素材列回報，交人類更新 manifest / 走 Q-ART。
- 遵守 `Docs/04` 版面不變量：操作 UI 仍在 y≥1300、角色不被蓋。

## 對齊清單（逐元件：現況 → 參考圖目標 → 該做的視覺調整）
| 元件 | 現況 | 參考圖目標 | 調整（純視覺） |
|---|---|---|---|
| HUD 三欄 | 米白卡、單一 label（小標+數字同字級 34） | 大而粗的數字、上方小標、欄位有 icon、分隔明確 | 每張卡的單一 Label 可拆成「小標 Label(28) + 大數字 Label(54, 粗/高對比)」（純視覺層，不接資料邏輯改動）；加欄位 icon（見素材清單）；卡框換貼紙 9-slice |
| 金幣膠囊 | 膠囊 + 爪 icon + 34 | 同風格、icon 清楚、數字略大 | icon 換清楚貼紙、數字 36–40 |
| 下注標題 | 純色長條「下注金額」36 | 桃紅貼紙橫幅感 | 換桃紅貼紙橫幅底圖，字級維持或 38 |
| 下注數字 | 52 | 更大更粗 | 56–64、加粗感（用粗字或描邊色） |
| −／＋ 鈕 | 148×112、48 | 飽滿 Q 彈貼紙、青綠＋/暖色− | 換 9-slice 按鈕底 + 維持尺寸 |
| 快捷籌碼 | 細長膠囊 | 貼紙小膠囊、選中高亮 | 換籌碼貼紙底、選中態用青綠/金黃高亮 |
| 開始挑戰/挑戰下一隻 | 青綠純色 464×144 / 全寬 116 | 飽滿青綠貼紙 + 爪 icon | 換 9-slice 按鈕底 + 左側加爪 icon（尺寸不變） |
| 撤退領取 | 橘/桃純色 | 暖色貼紙 + 背包 icon | 換 9-slice 按鈕底 + 背包 icon |
| 結算面板 | 米白卡 + 標題 48/內文 34 | 貼紙卡、標題更醒目 | 換卡框 9-slice、標題 52、數字加粗 |

## 需生成的 UI 圖（agent-sprite-forge `$generate2dsprite`，單張、透明、9-slice 友善）
> 9-slice 用的框/按鈕：**中央大面積純色平整、裝飾與厚描邊只在邊緣四角**，否則拉伸會糊。來源尺寸：按鈕 256×256、卡框/面板 512×256，四角圓角約 48px。
- 卡框：`ui_panel_card`（米白貼紙卡，深藍粗描邊）、`ui_panel_banner_pink`（桃紅標題橫幅）
- 按鈕底：`ui_btn_primary`（青綠）、`ui_btn_warm`（撤退用暖橘/桃）、`ui_btn_small`（−／＋ 用）、`ui_chip`（快捷籌碼，含選中態 `ui_chip_active` 可選）
- icon 貼紙（256×256 透明）：`icon_stage`（關卡，貓爪）、`icon_multiplier`（倍率，閃電或星）、`icon_payout`（收益，魚乾/魚骨）、`icon_coin`（金幣）、`icon_paw`（開始挑戰用）、`icon_backpack`（撤退用）、`icon_plus`、`icon_minus`
> 全部走「視覺風格」一節的貓咪街頭美式卡通,和現有背景同一家族。

## 字體大小（具體目標，可微調）
HUD 小標 28 / HUD 大數字 54；金幣 38；下注標題 38；下注數字 60；−／＋ 48；籌碼 30；主要按鈕 40；決策按鈕 38；結算標題 52 / 內文 36。
> 字級調整後務必確認**不溢出、不被卡框裁切、觸控熱區仍足**。

## 視覺風格（生成素材時一律帶上；與背景同一家族）
流浪貓街頭冒險、美式簡約 cartoon game UI、bright colorful vector、clean shape、bold chunky outlines、sticker-like、rounded corners、children's book、high-contrast pastel-neon。
配色：亮粉紅/桃紅(強調/標題框)、水藍/青藍(資訊/主按鈕)、深藍(描邊/陰影/HUD 外框)、奶油白/淡米(卡片底)、青綠(確認/加號/正向)、橘黃/金黃(獎勵/星/強調數字)。
造型：大圓角、厚描邊（深藍/深紫藍、偏粗如兒童繪本）、貼紙感、飽滿 Q 彈、輕微色塊陰影。
禁止：日系動漫、二次元立繪、寫實、厚塗奇幻、暗黑硬派、金屬科幻、casino 寫實、低飽和灰暗、過度 3D、複雜漸層玻璃擬物。

## 接入/技術
- 卡框/按鈕：`StyleBoxTexture` 9-slice，`texture_margin_*` ≈ 圓角邊寬（40~56），content_margin 維持文字內距；套到**既有節點**，custom_minimum_size/anchors/offset **不變**（除非本卡「對齊清單」明列的位置/間距微調）。
- icon：以 `TextureRect` 或 Button `icon` 加入，不擠壓文字、不蓋住數字。
- Godot 匯入：非像素風 filter linear、mipmaps off。
- Fallback：任何 9-slice 拉伸不乾淨或缺圖 → 退回現有 code-styled（換貓咪配色），遊戲不可壞。
- 整理後素材放 `Assets/final/ui/`，命名同上（全小寫底線）；skill 中間產物不進 final。

## 驗收（完成前在 Godot 跑 + 截圖）
- 與參考圖並排，HUD/下注/決策/結算的**視覺分量明顯更接近**（數字大而粗、貼紙卡框、按鈕有 icon）。
- **功能與版面骨架完全沒變**：節點數量/互動/狀態切換一致；下注仍是單一項目；操作 UI 仍在底部、角色不被蓋。
- 文字清楚、不溢出、不被裁切；按鈕可點、9-slice 邊角不變形。
- 風格和背景一致。
- 附截圖：BETTING、REWARD_DECISION、SETTLE 各一張。

## 完成後（依 AGENTS.md 回報格式）
列出：生成的 UI 素材（id/來源尺寸/9-slice margins/用在哪節點）、改了哪些字級/位置、哪些走 fallback、`Assets/final/ui/` 清單、截圖。供人類更新 manifest 並補 Q-ART。

---

## Round 2 微調清單（依實機截圖回饋，全部用可量化數值）
> 第一輪已套上貓咪風，但與參考圖比仍「扁平、份量不足」。以下逐點修正，**數值是標靶**，做完務必截圖與 `Art/references/ui_mockup_battle.png` 並排自評。
> 仍遵守本卡「明確不做」：不改功能/結構/互動、下注維持單一項、不碰 Logo 與怪物、文字留 Label。

### R2-1 描邊加粗（最優先，這條最影響「貼紙感」）
- 所有卡框與按鈕的 9-slice 底圖：**深藍粗描邊，視覺寬度 8–10px**，描邊色 `#1B2A4A`（深藍）。
- 生成 9-slice 來源時就把粗描邊畫進去（中央仍純色平整供拉伸）；接入後 `texture_margin_*` 要 ≥ 描邊+圓角寬，避免描邊被拉伸糊掉。

### R2-2 數字/主字加重（解決「輕飄飄」）
- 關鍵數字（HUD 倍率/收益、關卡、下注數字、按鈕主字）一律加**文字描邊**製造份量：
  `theme_override_constants/outline_size = 8`、`theme_override_colors/font_outline_color = Color(#1B2A4A)`、字色用奶白 `#FFF6E6` 或深藍視底色而定。
- 字級（沿用前面，未到就補到）：HUD 小標 28、HUD 數字 **56**、下注數字 **60**、金幣 40、主要按鈕 **42**、結算標題 **56**。
- Baloo2 偏細,若有 ExtraBold 字檔可換;沒有就靠上面的 outline 補厚度。

### R2-3 下注標題粉紅橫幅（修真 bug：文字被裁切）
- 粉紅橫幅高度 **≥ 72px**，文字 `vertical_alignment = 1`(center)、`horizontal_alignment = 1`，左右內距 ≥ 24，確保「下注金額」**完整不被切**、垂直置中。

### R2-4 HUD 欄位 icon（解決「像貼歪的」）
- icon 尺寸 **48×48**，放在**小標文字左側同一行**（icon＋「關卡」），不要浮在卡片上邊框。
- icon 與卡片上緣留 ≥ 16 內距；三欄 icon 大小/基線一致。

### R2-5 結算標題不要長得像按鈕（解決層級混淆）
- 「撤退成功 / 挑戰失敗 / 完美通關」是**標題純文字**（大字 56 + 深藍描邊），**移除其按鈕底/外框**。
- 該面板**唯一的按鈕**是「再來一局」。

### R2-6 統一圓角與內距
- 卡片圓角 **32**、按鈕圓角 **28**（9-slice 來源與 texture_margin 一致）。
- 面板內距 left/right ≥ 28、top/bottom ≥ 20；文字不貼邊。

### R2-7 垂直節奏
- 金幣膠囊與 HUD 三欄卡之間留 **≥ 16px**，不重疊、不黏在一起。
- 按鈕與螢幕底/面板底留 ≥ 24，視覺不貼底。

### R2 驗收（必做）
- 三張截圖（BETTING/REWARD_DECISION/SETTLE）**與參考圖並排**，逐點對照 R2-1~R2-7 self-check，回報每點 pass/fail 與差異說明。
- 確認：功能/結構/互動未變、文字無裁切無溢出、9-slice 描邊邊角不糊、版面不變量未破。

---

## Round 2.1 微調（粗描邊 + 數字加重，改用「程式畫」確定性命中）
> Round 2 已修好 bug（R2-3/4/5）與生成素材，但 **R2-1 粗描邊** 與 **R2-2 數字加重** 仍未達標：
> 卡片/按鈕仍是「細的、淺色」邊，數字仍偏輕。
> **根因**：描邊交給了生成的貼圖（畫出來是細裝飾邊），無法控制粗細/顏色。
> **解法**：描邊與字重**改用 Godot 程式參數做**，不靠生成圖的邊——數值可控、必定命中。

### R2.1-1 卡片/按鈕描邊改用 StyleBoxFlat（不靠貼圖的邊）
- 卡片/面板/按鈕的外框，一律改用 **`StyleBoxFlat`** 畫：
  `border_width_*（四邊）= 8`、`border_color = #1B2A4A`（深藍）、`corner_radius_* = 卡 32 / 鈕 28`、底色用奶白 `#FFF6E6` 或對應按鈕色（青綠/暖橘/桃紅）。
- 生成的 9-slice 貼圖**可保留當中央填色/紋理**，但**描邊以 StyleBoxFlat 的 border 為準**（若貼圖自帶細邊會打架，就直接用純 StyleBoxFlat 不用貼圖邊）。
- `ui_skin.gd` 已有 `DEEP_NAVY` 常數，請確保它真的以 8px border 畫出來（目前畫面看起來沒生效，請改成 StyleBoxFlat border 並在 Godot 目視確認邊夠粗夠深）。

### R2.1-2 數字加描邊補份量（Label outline）
- 關鍵數字 Label（HUD 倍率/收益/關卡、下注數字、按鈕主字、結算標題）一律加：
  `theme_override_constants/outline_size = 10`、`theme_override_colors/font_outline_color = #1B2A4A`；字色奶白或深藍視底色。
- 目標：數字看起來「厚、黑、跳出來」，接近參考圖份量。

### R2.1 驗收
- 裁切局部放大確認：**卡片/按鈕外框 ≈ 8px 深藍、不是細淺色邊**；**數字有明顯描邊厚度**。
- 三狀態截圖與參考圖並排，R2-1 / R2-2 兩點明確 pass。
- 功能/結構/版面不變量未破。

---

## Round 3 微調（HUD 三欄卡 + 下方操作區改用「生成的 9-slice 貼圖皮膚」）
> 目標：把使用者最不滿的兩塊——**HUD 三欄卡** 與 **下方操作區（下注面板/按鈕/籌碼）**——從程式 StyleBoxFlat 升級成**生成的貼圖皮膚**，做出參考圖的插畫質感（柔和漸層、貼紙立體感），這是 StyleBoxFlat 給不了的。
> **本次只動這兩塊的皮膚**；不碰怪物、標題 Logo、背景、戰鬥訊息。文字一律留 Label。

### 為什麼能精準貼齊
皮膚透過 `StyleBoxTexture` 9-slice **貼到既有節點的已知矩形**（下表），尺寸由節點 `custom_minimum_size` 決定、不變動。精準來自節點矩形，不是對齊大圖。

### 唯一改動點（兩個 chokepoint 函式）
`Scripts/ui/ui_skin.gd` 的 **`apply_panel(panel, style)`** 與 **`apply_button(button, style)`**：
- 改成「**對應 style 有生成皮膚 PNG → 用 `StyleBoxTexture` 9-slice；否則 fallback 現有 `_sticker_box`（StyleBoxFlat）**」。
- `StyleBoxTexture`：`texture_margin_*` ≈ 圓角+描邊寬（約 48），`content_margin` 維持現有內距；**不改任何節點尺寸/結構**。
- 其餘 apply_*（文字/icon/ribbon）維持不動。

### 節點 → style → 尺寸 對應（本次範圍）
| 區塊 | 節點 | 套用呼叫 | 節點尺寸 |
|---|---|---|---|
| HUD 關卡卡 | `Hud/Columns/StageCard` | `apply_panel(_, "card")` | 300×164 |
| HUD 倍率卡 | `Hud/Columns/MultiplierCard` | `apply_panel(_, "card")` | 300×164 |
| HUD 收益卡 | `Hud/Columns/PayoutCard` | `apply_panel(_, "card")` | 300×164 |
| 下注面板大框 | `ActionArea/BetPanel/Panel` | `apply_panel(_, "large")` | ~984×470 |
| 下注 − 鈕 | `…/BetRow/DecreaseButton` | `apply_button(_, "step_decrease")` | 148×112 |
| 下注 ＋ 鈕 | `…/BetRow/IncreaseButton` | `apply_button(_, "step_increase")` | 148×112 |
| 快捷籌碼 | `…/QuickChipRow/*`（動態） | `apply_button(_, "chip"/"chip_selected")` | ~138×72 |
| 開始挑戰鈕 | `…/Layout/ConfirmButton` | `apply_button(_, "primary")` | 全寬×116 |
| 撤退領取鈕 | `ActionArea/DecisionPanel/Buttons/CashoutButton` | `apply_button(_, "secondary")` | 464×144 |
| 挑戰下一隻鈕 | `…/Buttons/AdvanceButton` | `apply_button(_, "primary")` | 464×144 |
> 不在本次範圍：ProfileFrame、SettlementPanel、BattleMessage（保持現狀，之後再說）。

### 要生成的皮膚 PNG（`$generate2dsprite`，單張、透明、無文字、9-slice 安全）
放 `Assets/final/ui/`；命名 `skin_<style>.png`：
| 檔名 | 對應 style | 來源尺寸 | 色 | 備註 |
|---|---|---|---|---|
| skin_card.png | card | 512×288 | 奶白底+深藍厚描邊 | HUD 卡 |
| skin_panel.png | large | 512×512 | 奶白底+深藍厚描邊 | 下注大框 |
| skin_btn_primary.png | primary | 512×256 | 青綠 | 主要/挑戰 |
| skin_btn_secondary.png | secondary | 512×256 | 暖橘/桃 | 撤退 |
| skin_btn_minus.png | step_decrease | 256×256 | 桃紅 | − 鈕 |
| skin_btn_plus.png | step_increase | 256×256 | 青綠 | ＋ 鈕 |
| skin_chip.png | chip | 256×128 | 青藍邊 | 籌碼一般 |
| skin_chip_active.png | chip_selected | 256×128 | 青綠/金黃高亮 | 籌碼選中 |

**生成品質硬規則（這是上次失敗的關鍵）**：
- **無任何文字/數字**（文字由 Label 疊上）。
- **厚深藍描邊（#1B2A4A，視覺 ≥8px）** + 大圓角（卡 32 / 鈕 28）。
- **中央大面積平整、可拉伸**，柔和內漸層/輕陰影只在邊緣與四角 → 9-slice 拉伸才乾淨。
- 風格同貓咪參考圖（美式 cartoon、貼紙感、高彩度），和現有 icon/背景同家族。

### 不做
- 不改功能/狀態/數值/互動；不改節點數量/尺寸/anchors/offset（只換 stylebox）。
- 不碰怪物、標題 Logo、背景、SettlementPanel、BattleMessage。
- 文字不內嵌進圖；不改 Data；不改 Art/ART_CONTRACT（locked）。

### Fallback（鐵則）
任一 skin PNG 缺檔 / 載入失敗 / 9-slice 拉伸不乾淨 → 該 style **退回現有 `_sticker_box`（StyleBoxFlat）**，遊戲與既有外觀不可壞、不可退步。

### 驗收（Godot 目視 + 截圖）
- BETTING 與 REWARD_DECISION 兩狀態截圖**與參考圖並排**：HUD 卡、下注面板、−/＋、籌碼、開始挑戰/撤退/挑戰下一隻 的質感明顯接近參考圖（漸層/貼紙感）。
- 局部放大確認 9-slice 邊角不變形、描邊厚實。
- 功能/版面不變量未破；缺一張 skin 時該元件 fallback 正常。
- 回報生成的 skin 清單（檔名/來源尺寸/texture_margin/對應 style）。

> 治理註：若生成皮膚效果勝過程式畫並採用，會回頭修訂 `DECISIONS.md` D-012（由人類於 review 後記錄 / 補 Q-ART）。
