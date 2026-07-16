# 任務 28：一頁式遊戲介紹網站＋內嵌遊戲（Codex 執行）

> 依 `Docs/DECISIONS.md` **D-026**（人類 2026-07-16 裁示）。
> 一句話：做一個對外的一頁式介紹網站（理念、玩法、機制、怪物圖鑑），
> 把已上線的遊戲用 iframe 內嵌進頁面，隨既有部署腳本一起上到
> `https://crushgamedemo-bloop.web.app/intro/`。
> **本卡完全不碰遊戲本體**：不動 `Scripts/`、`Scenes/`、`Data/` 內容、
> `project.godot`、`Assets/`。

## 一、背景與內容來源（先讀）

| 來源 | 用途 | 權限 |
|---|---|---|
| `Web/landing/DESIGN.md` | **視覺規範（必讀必遵守）**：標準色票（取自 `ui_skin.gd`）、字體、元件語彙、素材使用、調性 | 已由 Claude 建立；有異議寫 OPEN_QUESTIONS，不得自行改色 |
| `Planning/11_GAME_CONCEPT_AND_GAMEPLAY.md` | 文案主來源：理念、玩法、四層樂趣、未來擴充 | **唯讀**（AGENTS.md 鐵則 10：不動 Planning，本卡只授權讀取） |
| `Data/monsters.json` | 怪物 id/stage/HP/`placeholder_color`/`art_asset_id` | 唯讀，經 build script 複製 |
| `Data/ui_text.json` | 怪物中文名（`monster_00N_name`）、遊戲語彙（落袋為安、過關…） | 唯讀，經 build script 複製 |
| `Data/game_balance.json` | 基準倍率曲線、危險度分級、下注範圍、虎爺事件參數 | 唯讀，經 build script 複製 |
| `Assets/final/`（logo、title_banner、背景 jpg、`boss/*.png+json`、`huye.png`） | 頁面視覺素材 | 唯讀，經 build script 複製 |
| `Firebase/README.md`、`Firebase/deploy_game.ps1` | 部署方式 | deploy 腳本本卡要擴充 |

對外名稱一律用 **《Meow準快跑》**（D-026）。遊戲內 logo/標題是「勇者撤離戰」，
若視覺上衝突，hero 區改用純文字主標＋把 `logo.png` 移到內嵌遊戲區塊當裝飾即可，
不要改任何遊戲素材。文案句子人類保留改句權（同 D-019 慣例）。

## 二、交付物（檔案清單）

```
Web/landing/
  DESIGN.md         視覺規範（已存在，勿改；隨站部署可排除）
  index.html        單頁入口
  style.css         全部樣式（可拆 1–2 支，不強制）
  main.js           資料載入 + 渲染 + 怪物 sprite 動畫
  build.ps1         把 Data/*.json 與 Assets/final 所需素材複製進 assets/（ASCII-only）
  assets/           build.ps1 產物，**gitignore，不進版控**
Firebase/deploy_game.ps1   擴充：呼叫 build.ps1 並把 Web/landing 複製到 export/web/intro/
.gitignore                 加 Web/landing/assets/
Codex/VALIDATION_CHECKLIST.md   補本卡驗收段
```

`build.ps1` 至少複製：`Data/monsters.json`、`Data/ui_text.json`、
`Data/game_balance.json`、`Assets/final/logo.png`、`Assets/final/title_banner.jpg`、
`Assets/final/background_battle_001~003.jpg`、`Assets/final/huye.png`、
`Assets/final/boss/boss1_idle ~ boss10_idle` 的 `.png`+`.json`。
（沿用 `deploy_game.ps1` 慣例：**PowerShell 檔保持 ASCII-only**，PS 5.1 會誤讀無 BOM 的 UTF-8 中文註解。）

`build.ps1` 另須用 System.Drawing 把每隻 boss 序列圖**預裁第一格**存
`assets/bossN_card.png`（長邊約 512px；frame 座標讀 TexturePacker JSON）——
圖鑑預設載小圖，完整 sheet 只供 idle 動畫、進視口才 lazy 載（DESIGN.md §十-1）。

## 三、頁面規格（由上而下）

> 版面骨架、tokens、反樣板、手作感細節、效能門檻**全部依 `DESIGN.md` §六–§十**
> （定案，不是建議）。本節只定各區塊「要有什麼內容」。特別注意 DESIGN.md §六：
> 桌機為左內容＋右 sticky 手機殼雙欄，非單欄堆疊。

1. **Hero 區**：主標《Meow準快跑》＋一句 tagline（取材 Planning/11 §一：
   風險撤離型、流浪貓街頭冒險）。兩顆 CTA：「立即遊玩」（平滑捲動到內嵌區）、
   「新分頁開啟遊戲」（`target="_blank"` 開 `https://crushgamedemo-bloop.web.app/`）。
   背景可用 `background_battle_001.jpg` 加暗色遮罩。
2. **內嵌遊戲區**：
   - 9:16 直式 iframe，外框做成手機外殼樣式；高度以 `min(85vh, …)` 封頂，寬度按比例。
   - **click-to-load**：先顯示 `title_banner.jpg` 海報＋播放鍵，點擊後才建立
	 iframe（`src="https://crushgamedemo-bloop.web.app/"`，**絕對網址**）——
	 遊戲 wasm/pck 很重，不可隨頁面自動載入。
   - iframe 屬性：`allow="autoplay; fullscreen"`；**不得加 `sandbox`**
	 （會擋 Google 登入 popup）。
   - 旁邊附註：手機直式體驗最佳＋「新分頁開啟」備援連結。
   - **手機（<1024px）不做內嵌（人類 2026-07-16 裁示）**：海報卡＋「開始遊戲」
	 按鈕＝**同分頁導頁**到 `https://crushgamedemo-bloop.web.app/`（遊戲本來就是
	 手機直式 H5，原生滿版體驗優於任何 iframe 包裝；返回鍵自然回介紹頁）。
	 手機上**不建立任何 iframe**、不做滿版 overlay。
   - 桌機（≥1024px）維持 sticky 手機殼內嵌＋click-to-load。iframe 只在桌機
	 版面存在（CSS 藏手機版 iframe 仍會載入，須用 matchMedia 判斷後才建節點）。
   - viewport meta 照常：`width=device-width, initial-scale=1`。
3. **玩法區**：Planning/11 §二的核心循環，畫成流程（下注 → 挑戰 → 擊敗 →
   撤退或續戰 → 結算/排名），重點呈現兩選項對比卡：「落袋為安」vs「挑戰下一隻」
   （用 `ui_text.json` 的遊戲語彙）。
4. **機制區**（四張卡片）：
   - **倍率盤**：由 `game_balance.json > multiplier_curve` 渲染 stage 1–10
	 基準倍率（表格或階梯圖），標註「基準值，每局隨機微調、只揭示下一關」
	 （D-019）。**不得顯示成功率百分比**，全站皆同。
   - **危險度**：說明星級 1–5（`danger_display.max_level`），愈深愈危險。
   - **虎爺降臨**：隨機救援事件——瀕敗時虎爺登場擊飛怪物、本局收益整體翻倍
	 （`random_events.huye.payout_factor` 讀出來顯示成「x2」語言）。素材用 `huye.png`。
   - **排行榜**：非同步競爭，撤退/敗北都能看到排名與超越百分比。
5. **怪物圖鑑區**：10 隻全列。每卡：怪物圖、中文名（`ui_text.json`）、
   關卡 Stage N、危險度星級。渲染規則：
   - 名稱、stage、順序一律來自 fetch 的 JSON，**不得硬寫在 HTML/JS**。
   - 危險度星級在前端由 `success_rate_curve` × `danger_display.levels` 推導
	 （對 stage 取 success_rate，由上往下取第一個 `success_rate ≥ min_success_rate`
	 的 level）；只顯示星星，不顯示 success_rate 本身。
   - 怪物圖來自 `bossN_idle.png` 序列圖＋TexturePacker JSON：至少正確裁出
	 第一格（canvas 或 `background-position`，尺寸讀 JSON 的 frame x/y/w/h）；
	 **正式需求**：以低 fps 循環播 idle 動畫（進視口才播、離開暫停、
	 reduced-motion 停格；預設顯示 build.ps1 裁好的 `bossN_card.png` 小圖，
	 sheet lazy 載，見 DESIGN.md §九-4／§十-1）。
   - 任一素材缺檔 → fallback 顯示 `placeholder_color` 色塊＋名稱，頁面不壞。
6. **頁尾**：本作為 AI 遊戲開發工作流展示專案（一句話即可）、
   「排行榜含模擬 NPC 資料」揭露（沿 D-020 對評審誠實原則）、年份。

## 四、技術規範

0. **視覺一律遵守 `Web/landing/DESIGN.md`**：顏色只能用該檔色票（建議直接
   定成 CSS custom properties）；素材只用該檔列出的 `Assets/final/` 項目；
   不得自行生成美術或引外部圖庫。
1. **純靜態 vanilla HTML/CSS/JS**：無框架、無 npm、無打包步驟（D-026）。
2. **資料驅動**：頁面執行期 `fetch('assets/…json')` 渲染；數值/怪物名/倍率
   不得寫死（AGENTS.md 鐵則 6 精神延伸到本站）。文案敘述句可寫在 HTML。
3. **RWD**：桌機（≥1024px）與手機（375px）都要能讀；手機上圖鑑改單/雙欄。
4. **字型**：沿 D-009 精神——標題可用 Google Fonts 載 Baloo 2（本站是網頁，
   允許外部字型連結）；中文用系統字型堆疊即可，不得引入非 OFL 專有字型。
5. **語言**：繁體中文（zh-TW），`<html lang="zh-Hant">`，補 SEO/OG meta
   （title、description、og:image 用 title_banner——**og:image 必須是絕對網址**，
   否則社群分享抓不到圖）。**favicon 必做**：從 `ui/icon_paw.png` 或 `icon_coin.png`
   產出（build.ps1 縮圖即可），不得留 Firebase 預設或空 favicon。
6. **效能**：圖鑑圖 `loading="lazy"`；遊戲 iframe 依 §三-2 click-to-load；
   不引入任何大型 JS 函式庫。

## 五、部署與本機驗證

1. `Firebase/deploy_game.ps1` 擴充（在 firebase deploy 之前）：
   呼叫 `Web/landing/build.ps1` → 把 `Web/landing/`（含 assets/，排除 build.ps1）
   複製到 `export/web/intro/`。遊戲本體檔案與根路徑完全不動。
2. 本機驗證：`firebase serve --only hosting --config firebase.game.json`
   （superstatic，**不需 Java、不是 Emulator Suite**，見 `Firebase/README.md` 鐵則）
   或任意靜態 server。**不可只用 `file://` 開**——fetch JSON 會被 CORS 擋，
   看起來像壞掉其實是驗證方式錯。
3. 部署免授權（人類 2026-07-05 裁示）：`.\Firebase\deploy_game.ps1` 直接上線，
   於 `https://crushgamedemo-bloop.web.app/intro/` 驗證；瀏覽器記得 Ctrl+Shift+R。
4. 前置條件：`export/web/index.html` 必須存在（腳本既有檢查會擋）。若本機
   沒有現成 Web export，先照 `Firebase/README.md` 的無頭匯出指令產一份。

## 六、不得改動

1. 遊戲本體：`Scripts/`、`Scenes/`、`project.godot`、`Data/*.json` **內容**、
   `Assets/`（只讀不寫）、`Art/ART_CONTRACT.md`。
2. `Planning/` 任何檔案（唯讀取材）。
3. Firebase rules、`firebase.game.json` 的 `public` 路徑、
   `Firebase/public/`（測試頁）、`crush-online.js`。
4. 不新增第二個 hosting site、不動遊戲根路徑 URL、不加自訂網域。
5. 不做多頁、後台、留言、分析追蹤等擴充；一頁式為止。

若判斷必須動到上述清單，先停下寫 `Docs/OPEN_QUESTIONS.md`，不得自行擴卡。

## 六之一、交付流程（兩階段，強制）

1. **階段一：視覺打樣**——先只做 hero 區＋機制四卡中的一張（含 DESIGN.md tokens
   全套落地）的靜態版，附桌機＋手機截圖**停下等人類過目**。人類本身是前端工程師，
   會直接裁決視覺方向；此時修改成本最低。
2. **階段二：人類點頭後**才展開全頁、互動與部署。階段一被退件不算失敗，
   算流程正常運作；不得跳過階段一直接交全頁。

## 七、驗收方式

1. 本機 `firebase serve` 全頁走查：六大區塊齊全、無 console error、
   JSON fetch 正常（怪物 10 隻、倍率 10 階皆由資料渲染）。
2. 改 `Data/ui_text.json` 任一怪物名 → 重跑 build.ps1 → 頁面同步變化
   （證明資料驅動；驗完改回來，git diff 必須乾淨）。
3. 暫時改名一個 boss png 模擬缺檔 → 圖鑑該格 fallback 色塊、頁不壞（驗完還原）。
4. 部署後線上驗證：
   - 桌機 Chrome：內嵌遊戲點擊載入後可完整玩一局（下注→戰鬥→撤退→結算）；
	 **實測 iframe 內 Google 登入 popup 可開啟**（需真實點擊）。
   - 手機寬度（DevTools 375×812 觸控模擬）：版面不破；點「開始遊戲」同分頁
	 導到遊戲、返回鍵回到介紹頁且捲動位置合理；**Network 面板確認手機版
	 未建立 iframe、未載入任何遊戲資源（wasm/pck）**。
   - 遊戲原網址 `https://crushgamedemo-bloop.web.app/` 行為與部署前一致
	 （本卡不得影響遊戲本體）。
5. 全站搜尋確認頁面上沒有出現任何成功率百分比。
5-1. 對照 `DESIGN.md`：CSS 內出現的每個色值都能對回色票表（含透明度變化）；
   金色僅用於收益/獎勵/虎爺語彙。
5-2. `DESIGN.md` §八反樣板清單逐條走查，一條都不能中；§九手作感細節逐條落實。
5-3. Lighthouse 手機模擬 Performance ≥ 90、CLS < 0.1（DESIGN.md §十）；
   附報告數字於完成回報。首頁初載不得下載任何完整 boss sheet（Network 面板證明）。
6. 附桌機與手機寬度整頁截圖，供人類目視驗收（版面美感人類說了算）。

## 完成後必須回報

依 `AGENTS.md` 完成回報格式：檔案清單、逐點對照 §三/§四、驗收證據（截圖＋
登入 popup 實測結果）、偏離取捨、新增 OPEN_QUESTIONS、下一步建議
（例：是否要把 landing 升為站點首頁、遊戲改掛子路徑——此屬範圍變更，須人類裁示）。
