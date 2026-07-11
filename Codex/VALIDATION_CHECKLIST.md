# VALIDATION CHECKLIST — 每輪驗收清單

> 每完成一張任務卡，對照本檔該段逐項打勾再回報。未過不得進下一張卡。

## 通用（每張卡都檢查）
- [ ] 只動了該任務卡範圍內的檔案。
- [ ] **資源存在性判斷一律用 `ResourceLoader.exists()`，不可用 `FileAccess.file_exists()`**——後者在匯出版對 imported 資源（PNG/MP3…）恆為 false，會讓缺檔 fallback 全部誤觸發（編輯器正常、部署後素材消失；2026-07-04 教訓，raw 檔如 .json 除外）。涉及素材/音訊載入的卡，**必須做一次 H5 匯出實機驗證**，不能只在編輯器目視。
- [ ] 沒有把數值/文案寫死（皆讀 `Data/*.json`）。
- [ ] 程式依 `Scripts/` 分層，無單一巨大 script。
- [ ] 不明確處已寫入 `Docs/OPEN_QUESTIONS.md`。
- [ ] 已用「完成回報」格式回報。

## 里程碑 1 — 任務 01（骨架+資料載入）
- [ ] 啟動無錯誤，顯示直式標題畫面。
- [ ] 5 個 JSON 皆成功載入；解析失敗會明確報錯。
- [ ] 改 `default_bet` 重啟能讀到新值。

## 里程碑 2 — 任務 02（狀態機+下注閉環）
- [ ] 狀態與轉移對應 `03_STATE_MACHINE.md`。
- [ ] 可走完 下注→挑戰→勝/敗→決策→結算→回下注。
- [ ] 收益隨 stage 符合 `multiplier_curve`。
- [ ] 勝率粗略趨近 `success_rate_curve`；餘額無負數。

## 里程碑 3 — 任務 03（戰鬥演出+怪物切換）
- [ ] 連擊→受擊掉血→死亡→倍率提升 演出可理解。
- [ ] 連擊數落在怪物 `attack_hits_range`。
- [ ] 走路+轉場+新怪物入場正常；失敗反擊演出正常。
- [ ] 改 `hit_interval` 節奏改變。
- [ ] **版面不變量（Docs/04 §二之二）：角色落在戰鬥區（y 400–1240）、站在大致相同地面線（主角左、怪物右）；角色與任何 UI/操作（含 debug 暫代）面板不重疊。在 Godot 內目視確認。**

## 里程碑 4 — 任務 04（直式 UI）
- [ ] 各狀態只顯示對應面板。
- [ ] 下注 −/＋ 受上下限步進限制；餘額不足禁用開始挑戰。
- [ ] 撤退按鈕即時顯示 payout。
- [ ] 縮放視窗 UI 不溢出。
- [ ] **操作 UI（下注/決策/結算）落在操作 UI 區（y ≥ 1300），不停在畫面中央；與戰鬥區角色不重疊；版面貼近示意圖 `Art/references/ui_mockup_battle.jpg` 並於 Godot 內目視確認（Docs/04 §二之一、二之二）。**

## 里程碑 5 — 任務 05（結算+本機分數）
- [ ] 撤退/戰敗/通關三種結算正確。
- [ ] 餘額與 best_payout 關閉重開仍保留。
- [ ] 核心只依賴 `ScoreService` 介面。
- [ ] Q-001（餘額不足）已依定案處理或明確標註。

## 里程碑 6 — 任務 06（手感+效果）
- [ ] 受擊 flash+震動、按鈕回饋、結算特效、收益跳動。
- [ ] 效果出錯不卡流程。
- [ ] 效果時長讀 JSON。

## 里程碑 7 — 任務 07（數值調校）
- [ ] 僅改 `Data/*.json`，未動 `.gd`。
- [ ] 難度/節奏手感合理；JSON 全部合法。
- [ ] 留有調校筆記。

## 里程碑 — 任務 09（UI 進場微動畫 + 提示文字節奏）
- [ ] 各面板出現有克制的淡入+上滑（不浮誇）。
- [ ] **連按 −/＋/快捷籌碼時面板不抖動**（只在 hidden→shown 觸發一次）。
- [ ] 提示文字淡入、停留足夠可讀、切換有節奏。
- [ ] 動畫時間讀 `animation_timing.json > ui`，改參數即生效。
- [ ] 動畫不阻塞流程、不破壞版面不變量（角色與 UI 不重疊）。

## 里程碑 8 — H5 Export 驗收（對照 `Docs/07`）
- [ ] `export/web/` 可於本機 HTTP server 開啟跑完一局。
- [ ] 直式比例正確、按鈕可點。
- [ ] 重整後 local 餘額/紀錄保留。

## 里程碑 — 任務 24（遇見虎爺救援事件；Codex）
- [x] `force_trigger=true` 完整演出：連擊→反擊慢動作→虎爺壓下→怪物左上旋轉縮小飛出→插頁與對話→爆金幣→決策。
- [x] 虎爺命中前不廣播勝利、不洩底；命中後強制勝且不消耗原勝負骰。
- [x] 收益驗證：觸發關增額 x2、後續保留固定 bonus、預測/決策/FOMO/結算同源、戰死歸零。
- [x] 專屬 RNG 機率統計近 `trigger_probability`；`enabled=false` 回歸原流程。
- [x] 後續關怪物 position/rotation/scale/visible/modulate 無殘留；缺 `huye.png` 時 fallback 不崩。
- [x] Godot 關鍵幀（慢動作/壓下/飛出/插頁）與後續怪物截圖已目視確認。
- [x] H5 匯出實跑完整 force-trigger 演出；素材存在性使用 `ResourceLoader.exists()`。

## 里程碑 — 任務 11（音效接入，需 D-014 定案後執行）
- [ ] BGM 開播且 loop；已映射 SFX 事件於對應時機發聲。
- [ ] 檔名/音量/loop 皆讀 `Data/audio.json`，改參數重啟即生效。
- [ ] **缺檔容錯**：移除單一音檔→該事件靜音不崩；刪除整個 `audio.json`→全程靜音仍可跑完一局。
- [ ] H5：首次互動前無聲且無 console 錯誤；首次點擊解鎖後 BGM 響起。
- [ ] 未動玩法/狀態機/版面/節點結構；未新增 UI。
- [ ] `Docs/SFX_TODO.md` 已更新各事件接檔狀態。

## 里程碑 — 任務 12（雲端佈建，需 D-015 定案後執行；執行者 Claude）
- [ ] 技術驗證通過：無 COOP/COEP 下 `signInWithPopup`（Google）可完成登入。
- [ ] Firebase 專案建立、Google provider 啟用、Firestore rules 部署生效。
- [ ] rules 實測：本人可讀寫自己分數；未登入/跨 uid 被拒。
- [ ] `Firebase/` 設定檔進版控；無任何 secret 入 repo。
- [ ] 佈建全程步驟紀錄 + 截圖齊備（簡報素材）。
- [ ] 憑證/授權皆由人類親手操作（回報中聲明）。

## 里程碑 — 任務 13（線上分數接入，需任務 12 完成後執行）
- [ ] H5 可 Google 登入；結算後 Firestore 更新自己分數；重整還原正確。
- [ ] 未登入/離線/拒絕登入 → 自動退回本機，遊戲完整可玩、無 console 錯誤。
- [ ] 桌面編輯器行為與接入前完全一致（core 只認 ScoreService 介面）。
- [ ] 雲端呼叫非同步不阻塞；僅結算時寫入。
- [ ] 登入鈕遵守版面不變量（Godot 目視 + 截圖）；文案讀 `ui_text.json`。

## 里程碑 — 任務 15（排行榜服務層 Mock，需 D-016；Codex）
- [ ] `request_top(10)` 含本人、排序正確；改 `leaderboard_mock.json` 排名即變（資料驅動）。
- [ ] `request_rank_for()` 排名/百分比與手算對照一致（附一組數字）。
- [ ] `submit_best` 低於既有紀錄不生效；僅撤退成功時提交。
- [ ] NPC 名單在 JSON、非 .gd；整局流程行為與現狀一致。

## 里程碑 — 任務 16（排行榜 UI 四接觸點，需任務 15 完成；Codex）
- [ ] 四接觸點齊備且方向符合 mockup：下注入口／決策排名提示／撤退成功結算欄／失敗結算欄。
- [ ] 排行榜面板：Top 10、本人高亮、關閉正常；戰鬥中不可開啟。
- [ ] 改 mock json → 各畫面數字全變；改 ui_text → 文案全變。
- [ ] 版面不變量不破壞（**Godot 目視 + H5 實機皆截圖**）。

## 里程碑 — 任務 17（排行榜 Firebase Phase 2，人類啟動後；Claude）
- [ ] rules 四象限實測 + 降分被拒；`users/` 私人欄位未暴露。
- [ ] 換資料來源後 UI 與 core 零修改；未登入/失敗 fallback 不崩。

## 里程碑 — 任務 18（怪物序列圖接入，需 D-017；Codex）
- [ ] stage 1–9 顯示對應 idle 動畫；面向左、地面線對齊、不壓 UI（編輯器目視截圖）。
- [ ] 切格以各自 `.json` 的 frame 座標為準（非假設同一 grid）；fps 讀 `animation_timing.json`。
- [ ] stage 10 與缺檔案例退 placeholder 不崩（實測移除一張 png）。
- [ ] `monsters.json`/manifest 僅資料欄位更新；存在性判斷用 `ResourceLoader.exists()`。
- [ ] **H5 實機**：九隻動畫正常、整局無卡頓（素材量大，材質/效能務必實測）。

## 里程碑 — 任務 19（怪物死亡爆金幣→吸入收益→跳數；Codex）
- [ ] 三階段順序正確：噴發→吸入收益欄→**第一枚到達才開始跳數**（錄影/連續截圖佐證）；死亡→轉場時序與現狀一致。
- [ ] 金幣終點落在收益數字上（編輯器 + **H5 實機**皆確認——座標轉換易在縮放後露餡）。
- [ ] 數值全讀 `animation_timing.json > effects.coin_burst`（改 json 效果即變，實測）。
- [ ] 保底生效：缺 `icon_coin.png`（ResourceLoader.exists 判斷）→ 無特效但數字照跳（max_hold）、整局可玩不崩；顯示值永不停在舊數。
- [ ] 高 stage 金幣數 > stage 1；連打多局節點無殘留。
- [ ] 未改任何 `.tscn`；state_machine 數值與 `monster_death_finished` 時機零改動。

## 里程碑 — 任務 20（決策資訊賭場化：拿血條/危險度/賠率語言/FOMO；依 D-019；Codex）
- [ ] 血條不再顯示；戰鬥演出節奏（hit/死亡時機）與現狀一致（前後對照）。
- [ ] 危險度分級讀 `game_balance.json > danger_display`（改門檻即變）；icon 缺圖 fallback 文字不崩。
- [ ] 決策畫面：「過關可得 {金額}」主視覺 +「1 賠 N」副標 + 危險度；**全畫面無成功率 % 字樣**。
- [ ] 結算 FOMO 行正確：撤退=「若再過一關可得…」（通關時隱藏）、戰敗=「上一關落袋…」（第 1 關戰死時隱藏）。
- [ ] 文案全走 `ui_text.json`（改 json 即變）；程式不依賴字串內容；烙字按鈕素材未動。
- [ ] 版面不變量成立（Docs/04；操作 UI y≥1300）；場景改動已 Godot 目視 + **H5 實機**截圖。

## 里程碑 — 任務 21（每局隨機倍率盤；依 D-019；Codex）
- [ ] 每局擲一次本局盤：連開多局下一關倍率不同、同局內同一關數值不變。
- [ ] 單調遞增恆成立 + 抖動低關小高關大（100 局打印驗證）。
- [ ] `enabled=false` → 與原 `multiplier_curve` 逐位一致（回歸路徑實測）。
- [ ] 參數全讀 `game_balance.json > multiplier_random`（改 json 行為即變）。
- [ ] success_rate 查表/擲骰/狀態時序零改動；顯示倍率與計算倍率同源；收益仍 floor。
- [ ] 不揭示全曲線（只有下一關）；**H5 實機**整局可玩、排行榜寫入正常。

## 里程碑 — 任務 22（大贏插頁：金色數字慶祝畫面；Codex）
- [ ] 撤退/通關進結算先出插頁（暗底+標題+金色數字 count-up+提示）；點擊後露出結算面板；戰敗無插頁。
- [ ] 千分位數字正確（3 位/5 位/含 0 三例截圖）；缺 digit 圖 → 文字版 fallback 照常可關不崩。
- [ ] `min_show` 內點擊無效、`auto_dismiss` 逾時自動收（實測）；插頁存活期間結算按鈕不可被誤觸。
- [ ] 數值全讀 `animation_timing.json > effects.win_banner`、文案讀 `ui_text.json`（改 json 即變）。
- [ ] 狀態機/settled 時序零改動；未動 `.tscn`；連打多局無節點殘留。
- [ ] windigits 十一張入 manifest；風格與現有 UI 家族一致；**H5 實機**觸控可關、無掉幀。

## 里程碑 — 任務 23（設計師 UI 參考圖視覺對齊；Codex）
- [x] TITLE 直接使用 `title_banner.jpg`，現有文字 Logo 不重複；互動鈕不遮主要 Logo。
- [x] BETTING／決策共用上半部，下注、危險度、排名提示與雙按鈕形成同一套粉紅／奶油／青藍街頭卡通語言。
- [x] 結算時隱藏 HUD／角色，只留街景與中央「結果」米色深藍框面板；內容仍使用既有動態資料。
- [x] 四組 Godot 實跑 vs 參考圖對照已產出；缺 `title_banner.jpg` 時退回舊背景＋文字 Logo，不崩。
- [x] H5 540×960 實機完整走過下注→過關決策→撤退→大贏插頁→結算→再來一局；無 console warning/error、無面板殘留。
- [x] 新文案走 `ui_text.json`、新素材已登記 manifest；所有圖片存在性判斷使用 `ResourceLoader.exists()`。

## 里程碑 9 — 任務 08（素材接入）
- [ ] `Assets/final/` 齊備素材正確顯示，符合 manifest 檔名/路徑。
- [ ] **缺檔自動 fallback placeholder，遊戲不崩**（移除某 final 素材重跑驗證）。
- [ ] 接入後動畫時序不變。
- [ ] 未修改 Art Contract；不符 Contract 的素材未硬接，已登記 Q-ART。
- [ ] manifest `status` 已更新為 imported（僅資料欄位）。
