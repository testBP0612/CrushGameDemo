# PPT 草稿三：Repo 證據實錄（終端機輸出附錄）

> 用途：比賽簡報的「證據頁」底稿。每一格都是**真實指令＋真實輸出**（2026-07-16、
> HEAD `56e0020` 實測），評審拿到 repo 可當場重跑，逐字對帳。
> 表現手法：PPT 上以「深色終端機視窗」樣式呈現，一頁最多 1–2 格，輸出節錄不造假；
> 節錄處一律標「（節錄）」。
> 狀態：草稿 v1（2026-07-16），待參賽者審核。還原方式見文末「重現說明」。

---

## 證據 0：先對帳——送件文件的錨定值 vs 送件日實測值

| 指標 | 08/09/10 送件口徑 | 2026-07-16 實測 | 差異說明 |
|---|---:|---:|---|
| Git commits | 120+（保守下限） | **136** | 申報低於實際 ✓ |
| 任務卡 | 27 張全數完成 | **28 張**（01–27 完成；28 landing page 進行中） | 完成數申報吻合 ✓ |
| 人類決策 | 25 筆 | **26 筆**（D-026 於送件週新增） | 申報低於實際 ✓ |
| AI 提問 | 12 筆全 ANSWERED | **12 筆全 ANSWERED** | 完全吻合 ✓ |
| GDScript | 36 份、5,500+ 行 | **36 份、5,620 行**（非空白行） | 申報低於實際 ✓ |
| 正式素材 | — | **213 檔**（`Assets/final/`） | — |

> 講者備註：這張表本身就是說服力——所有申報值都是保守下限，沒有一項灌水。
> 「數字只少報不多報」是評審最容易驗證的誠信訊號。

---

## 證據 1：開發期間（Git 第一筆到最後一筆）

```console
$ git log --reverse --format="%h %ad %s" --date=short | head -1
f38fe88 2026-06-27 Initial commit

$ git log -1 --format="%h %ad %s" --date=short
56e0020 2026-07-16 docs: card 28 stage-1 review verdict + DESIGN.md rulings

$ git rev-list --count HEAD
136
```

**證明**：2026-06-27 → 2026-07-16，約三週、136 個 commit，每一步可追溯。

---

## 證據 2：生產線不是口號——repo 根目錄就是流程本身

```console
$ ls
AGENTS.md      ← AI 行為鐵則（最高準則）
Art/           ← 美術合約與 prompt 樣板（v1.5 locked）
Assets/        ← final/（正式素材唯一入口）＋ placeholders/
CLAUDE.md      Codex/         ← 28 張任務卡＋驗收清單
Data/          ← 7 份 JSON，數值文案單一真實來源
Docs/          ← 規格＋OPEN_QUESTIONS＋DECISIONS 雙帳本
Firebase/      ← 雲端佈建紀錄與部署設定
Planning/      Scenes/  Scripts/  Tests/  Web/
project.godot  export_presets.cfg
```

**證明**：治理文件、任務卡、資料、程式、美術、雲端各有明確位置——
AI 與人類的交接介面就是這個資料夾結構。

---

## 證據 3：28 張任務卡，一次一張、各有邊界

```console
$ ls Codex/
00_MASTER_PROMPT.md                  15_LEADERBOARD_SERVICE.md
01_PROJECT_SCAFFOLD_AND_DATA_LOAD.md 16_LEADERBOARD_UI.md
02_STATE_MACHINE_AND_BETTING_LOOP.md 17_LEADERBOARD_FIREBASE.md
03_BATTLE_PRESENTATION_LOOP.md       18_MONSTER_ASSET_INTEGRATION.md
04_H5_VERTICAL_UI.md                 19_COIN_BURST_ON_MONSTER_DEATH.md
05_SETTLEMENT_AND_LOCAL_SCORE.md     20_DECISION_INFO_REVAMP.md
06_FEEL_AND_EFFECTS.md               21_RANDOM_MULTIPLIER_TABLE.md
07_DATA_BALANCE_TUNING.md            22_WIN_BANNER_INTERSTITIAL.md
08_ASSET_REPLACEMENT_GUIDE.md        23_UI_REFERENCE_ALIGNMENT.md
09_UI_FEEL_AND_PACING.md             24_HUYE_RESCUE_EVENT.md
10_UI_SKIN_ALIGNMENT.md              25_COIN_BURST_SFX_SPLIT.md
11_AUDIO_INTEGRATION.md              26_HUYE_EVENT_BGM.md
12_CLOUD_PROVISIONING.md             27_HUYE_JACKPOT_PACING_AND_FX.md
13_ONLINE_SCORE_INTEGRATION.md       28_INTRO_LANDING_PAGE.md
14_ONLINE_LOGIN_UI.md                VALIDATION_CHECKLIST.md
```

**證明**：從骨架到雲端到活動事件，每張卡是一個可驗收的閉環；
卡名即開發史（01–27 已完成驗收，28 進行中）。

---

## 證據 4：26 筆人類決策，append-only、推翻用新編號

```console
$ grep "^## D-" Docs/DECISIONS.md | head -12
## D-001：Godot 工程留在 repo root
## D-002：Art Contract v1.0 Freeze 流程
## D-003：美術風格由美術同事決定，Claude 只定規格
## D-004：placeholder-first + art-parallel（輕量素材流程）
## D-005：DataLoader 改為 autoload 單例 `Data`
## D-006：畫面分區改用具體座標契約 + 版面不變量
## D-007：餘額不足時重置為起始餘額（回應 Q-001）
## D-008：MVP 不做音效，只預留接口與空缺清單（回應 Q-002）
（節錄）

$ grep -c "^## D-" Docs/DECISIONS.md
26
```

**證明**：決策不是散在聊天紀錄裡，而是編號、可引用、不可竄改的帳本；
修訂舊決策用新編號（例：D-014 修訂 D-008），歷史全保留。

---

## 證據 5：12 筆 AI 提問，全數經人類裁示、零懸置

```console
$ grep "^### Q-" Docs/OPEN_QUESTIONS.md | grep -v "XXX"
### Q-001：餘額不足時的處理
### Q-002：是否需要音效 / 音樂
### Q-003：缺少正式 UI mockup 圖檔
### Q-ART-001：背景改為分區（新增 background_battle_002/003）
### Q-ART-002：新增 UI 素材類別（icon 貼紙；面板/按鈕改程式皮膚）
### Q-ART-003：sprite sheet 規則修正（加尺寸上限 + 允許 grid）
### Q-004：正式接入音效/音樂（修訂 D-008 的「MVP 不做音效」）
### Q-005：線上身分與分數服務（Google 登入 + 雲端記分）
### Q-006：排行榜（D-015 Future 項目啟用）
### Q-ART-004：怪物素材以動畫序列圖交付（命名/路徑與 v1.3 清單不符）
### Q-ART-005：背景素材改以 JPG 交付（格式與 §三/§五 不符）
### Q-007：賭場化體驗改版（拿血條、賠率語言、每局隨機倍率盤）

$ grep -c "狀態：ANSWERED" Docs/OPEN_QUESTIONS.md
12
```

**證明**：一般問題 7 筆＋美術問題 5 筆＝12 筆，每筆都停下等人類拍板後才動工，
`ANSWERED` 計數與清單逐筆對得上。

---

## 證據 6：一條完整證據鏈——Google 登入從提問到上線

```console
$ grep -A1 "^### Q-005" Docs/OPEN_QUESTIONS.md
### Q-005：線上身分與分數服務（Google 登入 + 雲端記分）
- 狀態：ANSWERED → 見 DECISIONS D-015

$ grep "^## D-015" Docs/DECISIONS.md
## D-015：線上身分與分數服務（Firebase BaaS，回應 Q-005）

$ ls Codex/ | grep -E "^1[234]"
12_CLOUD_PROVISIONING.md      ← Claude：CLI＋瀏覽器佈建
13_ONLINE_SCORE_INTEGRATION.md ← Codex：Godot 串接
14_ONLINE_LOGIN_UI.md          ← Codex：登入 UI
```

**證明**：超出 MVP 的需求 → AI 先提 Q-005（方案／風險／影響）→ 人類定案 D-015 →
才拆成三張卡實作 → 成品可登入。**任一功能都能這樣往回追。**

---

## 證據 7：數值文案零寫死——7 份 JSON 單一真實來源

```console
$ ls Data/
animation_timing.json   game_balance.json   monsters.json
audio.json              leaderboard_mock.json
battle_sequences.json   ui_text.json
```

**證明**：平衡、文案、怪物、動畫、音訊全部資料驅動（AGENTS 鐵則 6）；
換數值不動程式，換一款遊戲只換 `Data/`＋`Docs/`＋任務卡。

---

## 證據 8：美術合約鎖版＋213 個正式素材檔

```console
$ head -3 Art/ART_CONTRACT.md | grep 狀態
> 狀態：v1.5 locked 🔒（變更見 DECISIONS D-011、D-012、D-013、D-017、D-018）

$ find Assets/final -type f | wc -l
213

$ for d in Assets/final/*/; do echo "$d  $(find $d -type f | wc -l)"; done
Assets/final/audio/  30
Assets/final/boss/   30
Assets/final/ui/     122
```

**證明**：合約五次升版（v1.0→v1.5）每次都有 Q-ART 提案與 D 編號裁示；
AI 產出的素材不是散圖，是照合約命名入庫、遊戲直接引用的 213 個資產檔。

---

## PPT 表現建議（不上投影片）

1. **視覺**：深色終端機視窗（圓角、紅黃綠三個假窗鈕、等寬字型），一頁 1–2 格；
   指令用亮綠、輸出用白、重點數字用金黃放大。與現有兩份 PPT 的深藍封面同語系。
2. **用法**：不是每頁都塞終端機——建議只在「Q→D 機制頁」後插一頁「證據 5＋證據 6」，
   量化成果頁後插「證據 0 對帳表」。其餘留在附錄備查，評審提問時翻出來。
3. **殺手鐧是證據 6**（單一功能的完整證據鏈）與**證據 0**（全部申報值＝保守下限）。
   前者證明流程真的在跑，後者證明數字沒有一項灌水。
4. 若簡報只有一頁空間：放證據 6。一條鏈勝過十個數字。

## 重現說明

- 所有輸出於 2026-07-16、HEAD `56e0020`、repo 根目錄以 Git Bash 實測。
- `ls` 輸出為排版節錄（多欄併排、加註中文說明），檔名逐字未改；
  含「（節錄）」者為截斷，其餘為完整輸出。
- 後續 commit 會使 count 類數字增加；重跑以當下 HEAD 為準，方向只增不減。
