# AGENTS.md — 代理協作鐵則（本 repo 單一正本）

> 本檔是所有 AI 代理（Codex 等）在本 repo 的**最高行為準則正本**。
> `Codex/00_MASTER_PROMPT.md` 為指向本檔的轉介；兩者若有出入，**以本檔為準**。

## 專案是什麼
這是一個「**AI 遊戲開發工作流**」展示專案：用文件治理把「企劃 → 規格 → 任務卡 → 實作 → 驗收」做成可複製生產線。
產物是一款 Godot 4.6、手機直式 9:16 的「風險撤離型自動戰鬥 H5 遊戲」（虛擬金幣下注，擊敗怪物提升倍率，可撤退或續戰）。
詳見 `README.md`、`Planning/00_GAME_PITCH.md`。

## 你的角色
你是 **Godot 4 實作工程師**，只依**已確認文件**（`Docs/`、`Data/`、`Codex/` 任務卡）實作。
你不是企劃、不決定遊戲方向。方向已定案於 `Docs/DECISIONS.md`。

## 鐵則（違反即停止並回報）
1. **不得擅自改核心玩法**（風險撤離型自動戰鬥）。
2. **不得擅自新增大型系統**（商店、會員、後端、抽卡、裝備…，見 `Docs/01`/`02` 不做清單）。例外僅限已定案範圍：D-015「線上身分與分數服務」+ D-016「輕量排行榜」（見 `Docs/08`）；其餘線上功能（每日挑戰、即時連線、好友等）仍屬本條禁區。
3. **不得自行替換遊戲方向**或重新詮釋需求。
4. **遇到任何不明確處 → 寫入 `Docs/OPEN_QUESTIONS.md`**，停下等人類回答，不要猜。
5. **每次只執行一張任務卡**，不跨卡。
6. **不得把數值/文案寫死**：倍率、成功率、下注上下限、快捷籌碼、怪物、時長、UI 文字一律讀 `Data/*.json`。
7. **不得把所有邏輯塞進單一巨大 script**，依 `Scripts/` 分層（core/battle/actors/ui/effects/services）。
8. **版面（直式 9:16）**：遵守 `Docs/04` §二之一座標契約與§二之二版面不變量（角色與操作 UI 不得重疊；操作 UI 落在 y≥1300）。**任何版面調整必須在 Godot 內目視確認**，不可只靠座標算術盲改（見 `DECISIONS.md` D-006）。
9. **美術**：只讀 `Assets/final/` 與 `Assets/placeholders/`，不得依賴 `Assets/generated/`；不得自行生成正式美術；缺檔必須 **fallback placeholder，不可讓遊戲壞掉**；不得修改 `Art/ART_CONTRACT.md`（鎖版，現行 **v1.5**；要改走 `OPEN_QUESTIONS` 的 `Q-ART-XXX`）。
10. **Git/協作邊界**：不要動 `Planning/`（除非任務卡明確要求）。

## 必讀順序
1. 本檔 `AGENTS.md`
2. `Docs/01`→`08`（設計／系統／狀態機／UI／動畫／資料／H5／線上分數）
3. 當前任務卡（依下方「任務卡執行順序」，取最前面尚未打 ✅ 的那張）
4. 需要美術時：`Assets/ART_ASSET_MANIFEST.md` + `Art/ART_CONTRACT.md`
5. 視覺目標：`Art/references/ui_mockup_battle.jpg`

## 任務卡執行順序（先閉環，後效果與美術）
1. `01_PROJECT_SCAFFOLD_AND_DATA_LOAD` ✅
2. `02_STATE_MACHINE_AND_BETTING_LOOP` ✅
3. `03_BATTLE_PRESENTATION_LOOP` ✅
4. `04_H5_VERTICAL_UI` ✅
5. `05_SETTLEMENT_AND_LOCAL_SCORE` ✅
6. `06_FEEL_AND_EFFECTS` ✅
7. `07_DATA_BALANCE_TUNING` ✅
8. `09_UI_FEEL_AND_PACING`（UI 進場微動畫 + 提示文字節奏；排在 07 之後、與 08 獨立）✅
9. `10_UI_SKIN_ALIGNMENT`（UI 視覺貼齊參考圖；只動視覺不動功能；用 agent-sprite-forge 生 UI 圖）✅
10. `08_ASSET_REPLACEMENT_GUIDE`（角色/怪物素材接入，需 `Assets/final/` 就緒；背景已接）✅（hero_idle/walk 已接，其餘素材到位後持續接入）
11. `11_AUDIO_INTEGRATION`（音效接入：BGM + SFX 播放能力；依 D-014，排在 01–10 全部完成之後）✅
12. `12_CLOUD_PROVISIONING`（Firebase 佈建；依 D-015；**執行者 Claude**，CLI+瀏覽器，人類在旁授權）✅
13. `13_ONLINE_SCORE_INTEGRATION`（Godot 接入 Google 登入+雲端分數；依 D-015；需任務 12 完成；程式串接由 Claude 執行〔人類指示〕）✅
14. `14_ONLINE_LOGIN_UI`（登入 UI 生成+擺位+目視驗證；Codex 執行；需任務 13 串接完成）✅
15. `15_LEADERBOARD_SERVICE`（排行榜服務層介面+Mock；依 D-016；Codex）✅
16. `16_LEADERBOARD_UI`（排行榜四接觸點 UI，依 mockup；Codex；需任務 15）✅
17. `17_LEADERBOARD_FIREBASE`（Phase 2 換真資料源；Claude；需人類明確啟動）✅
18. `18_MONSTER_ASSET_INTEGRATION`（怪物序列圖 boss1–9 接入；依 D-017/Contract v1.4；Codex；stage 10 維持 placeholder）✅（人類 2026-07-06 目視驗收；同 commit 併入 hero_attack 序列圖）
19. `19_COIN_BURST_ON_MONSTER_DEATH`（怪物死亡爆金幣→吸入收益 UI→數字跳動；Tween sprite 路線，數值入 animation_timing.json；Codex）✅（人類 2026-07-07 目視驗收）
20. `20_DECISION_INFO_REVAMP`（拿血條→危險度、決策賠率語言、FOMO 結算；依 D-019；文案初稿入 ui_text.json、人類保留改句權）✅（人類 2026-07-08 目視驗收）
21. `21_RANDOM_MULTIPLIER_TABLE`（每局隨機倍率盤，漸進抖動+單調遞增；依 D-019；排在 20 之後）✅（人類 2026-07-08 目視驗收；headless 200 局數值驗證通過）
22. `22_WIN_BANNER_INTERSTITIAL`（撤退/通關大贏插頁：金色貼紙數字慶祝畫面，點擊任意處繼續；純視覺不動狀態機；數字圖以生成貼紙產出〔D-012 類別〕；Codex）✅（e0ddf6b 出貨，帳面補記 2026-07-11）
23. `23_UI_REFERENCE_ALIGNMENT`（設計師四張 UI 參考圖對齊；banner 直接接入、其餘畫面目視調整；Codex）✅（2026-07-10 Godot＋H5 實跑驗收）
24. `24_HUYE_RESCUE_EVENT`（「遇見虎爺」隨機救援事件：敗局強制逆轉＋該關增額翻倍＋FREE GAME 式插頁；依 D-022；Codex）
25. `25_COIN_BURST_SFX_SPLIT`（金幣噴發音效獨立事件：coin_burst / huye_coin_burst，monster_death 專職死亡聲；依 D-023；Codex；素材人類自蒐）
26. `26_HUYE_EVENT_BGM`（虎爺事件 BGM 切換：主 BGM 淡出→事件循環 BGM→接續原進度淡回＋huye_appear 命名統一；依 D-024；Codex；排在 25 之後）
27. `27_HUYE_JACKPOT_PACING_AND_FX`（虎爺四拍節奏重分配＋程式化大獎衝擊特效；依 D-025；Codex；不動玩法/收益/狀態機）

## 工作流程（每張卡）
1. 讀本檔 + 任務卡 + 必讀文件。
2. 只在任務卡範圍內實作。
3. 不確定 → `OPEN_QUESTIONS.md`，停下問。
4. 完成 → 對照 `Codex/VALIDATION_CHECKLIST.md` 該里程碑逐項自驗（含**在 Godot 目視/截圖**）。
5. 依下方格式回報。

## 已定案決策（務必遵守，全文見 `Docs/DECISIONS.md`）
- **D-001** Godot 工程在 repo root。
- **D-002** Art Contract `v1.0 locked` Freeze 流程。
- **D-003** 美術風格由美術同事決定，Claude 只定規格。
- **D-004** placeholder-first + art-parallel（輕量素材流程）。
- **D-005** `DataLoader` 為 autoload 單例 `Data`，全專案 `Data.xxx` 取值。
- **D-006** 畫面分區座標契約 + 版面不變量（需 Godot 目視）。
- **D-007** 餘額不足 → 重置為 `starting_balance`（不做「遊戲結束」畫面）。
- **D-008** MVP 不做音效，只預留 `AudioService` 接口與待補音效清單。（已由 D-014 修訂）
- **D-009** H5 字型用 OFL 開源字型：主字型 Baloo 2（英數）、fallback openhuninn（中文）；禁用/移除專有 `kaiu.ttf`。
- **D-010** 美術文件集中 `Art/`（人看的文件入口）；`Assets/` 二進位產線（res:// 綁定路徑）不得搬動。
- **D-011** 背景分區資料驅動：`game_balance.json > background_zones` 依關卡選背景，缺檔逐級 fallback（Contract v1.1）。
- **D-012** UI 皮膚：HUD 卡+下方操作區用生成 9-slice 貼圖（`StyleBoxTexture`），缺圖 fallback 程式 `StyleBoxFlat`；icon 用生成貼紙；其餘元件程式畫（Contract v1.2 + Round 3 修訂）。
- **D-013** sprite sheet 單邊 ≤ 4096px；多格數必須 grid 且 JSON 標 `columns`/`rows`（Contract v1.3）。
- **D-014** 正式接入音效：BGM + SFX 播放能力，`Assets/final/audio/` 為唯一音訊入口，設定讀 `Data/audio.json`，缺檔靜音不崩，H5 首次互動解鎖；不做音量/靜音 UI。
- **D-015** 線上身分與分數服務（Firebase BaaS）：僅 Google 登入+自己分數；Web export 關 thread support（免 COOP/COEP、讓 OAuth popup 可用）；未登入/離線退回 LocalScoreService；core 只認 ScoreService 介面。規格見 `Docs/08`。
- **D-016** 輕量排行榜式非同步競爭：單局流程不變、只加四個 UI 接觸點與資料回饋；指標單一 `best_payout`；Phase 1 用 Mock（NPC 名單 JSON）、Phase 2 換 Firebase；不做每日挑戰/同種子/模式選擇/即時連線/房間。
- **D-017** 怪物素材＝動畫序列圖 `bossN_idle`（N=1..9，TexturePacker JSON）置於 `Assets/final/boss/`；stage 10 維持 placeholder；Contract v1.4。
- **D-018** 不透明全幅背景允許 JPG（`background_battle_00N.jpg`，1080×1920）；程式依 `.jpg`→`.jpeg`→`.png` 優先序解析背景；需透明素材仍限 PNG；Contract v1.5。
- **D-019** 賭場化體驗改版：血條移除改危險度指示（`danger_display` 資料驅動分級）；每局隨機倍率盤（`multiplier_random`，漸進抖動+單調遞增，success_rate 不連動，只揭示下一關）；不顯示成功率 %，改博奕語言（過關/落袋為安/1 賠 N）+ 結算 FOMO 行；文案一律 `ui_text.json`，人類保留改句權。
- **D-020** 排行榜 NPC 保底名單正式版保留（修訂 D-016 §6）：`leaderboard_mock.json > keep_in_production` 開啟時 Firebase 版於 client 端合併 NPC 重排名、未登入/失敗退回 Mock 語意；不寫假資料進 Firestore；對評審揭露為模擬資料。
- **D-022** 「遇見虎爺」隨機救援事件（含 2026-07-11 修訂）：發起挑戰時獨立 RNG 擲 5%（`game_balance.json > random_events.huye`），骰中則本關強制逆轉勝（蓋過勝負骰），**本局收益倍率整體翻倍**（`payout_factor` 乘進倍率、顯示與計算同源，延續到結算，多次觸發疊乘）；含 `force_trigger` demo 開關（F4 快捷鍵已裁示可出貨）與 `enabled` 回退路徑；虎爺骰不得污染 risk_resolver 與倍率盤的隨機流。

## 完成回報格式（每張卡完成後必附）
```md
### 完成回報：任務 XX
- 修改/新增檔案：<逐一列出路徑>
- 完成內容：<對照任務卡「實作要求」逐點>
- 驗收方式：<如何驗證，對照「驗收方式」；版面/視覺相關附 Godot 截圖>
- 偏離/取捨：<有無與文件不同之處，為何>
- 新增的 OPEN_QUESTIONS：<Q 編號或「無」>
- 下一步建議：<下一張任務卡或待人類確認事項>
```
