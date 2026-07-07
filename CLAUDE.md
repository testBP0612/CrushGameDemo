# CrushGameDemo — 專案路由（給 Claude Code session）

本 repo 有自己的治理體系，**repo 治理優先於一般工作習慣**。全域制度見
`C:\Users\User\.claude\CLAUDE.md` 與 `playbooks/`。

## 開工前必讀（順序）

1. `AGENTS.md` — 本 repo 對 AI 的最高行為準則（短，必讀）。
2. `Docs/DECISIONS.md` 最後 2–3 筆 — 最新定案。
3. memory 的 `project_progress_state.md` — 目前做到哪、下一步。

## 本專案鐵則摘要（全文在 AGENTS.md，衝突時以 AGENTS.md 為準）

- 遇到模糊/範圍變更 → 寫 `Docs/OPEN_QUESTIONS.md`（Q-XXX）停下等人裁示，
  定案後寫 `Docs/DECISIONS.md`（D-XXX，append-only，推翻用新編號）。
- 數值/文案一律讀 `Data/*.json`，禁止寫死。
- `Scenes/*.tscn` 版面**不可盲改**——必須有人在 Godot 內目視確認（D-006）。
  Claude 負責規劃/規格/治理文件；Godot 內實作與目視驗證是 Codex/人類的事。
- 美術只讀 `Assets/final/` 與 `Assets/placeholders/`；`Art/ART_CONTRACT.md` 已鎖版，
  要改走 Q-ART 流程。
- 不動 `Planning/`；不擅增大型系統；一次一張任務卡。

## Firebase 相關工作

部署/測試/打包一律先讀 `Firebase/README.md`（含:**不要裝 Java/Emulator**，
用真環境驗證的完整做法；本專案部署免授權——人類 2026-07-05 裁示）。

## 現況錨點（2026-07-07 更新）

- **任務卡 01–18 全數完成，遊戲已上線 https://crushgamedemo-bloop.web.app**
  （含 Google 登入 + Firebase 雲端排行榜）。決策至 D-018、Q 全數 ANSWERED。
- 目前階段：**比賽準備**。簡報素材＝`Planning/07_DEMO_KIT.md`（含 demo 前待辦清單）；
  SFX 待補（9 事件全靜音，規格見 `Docs/SFX_PRODUCTION_LIST.md`，放檔+改 audio.json 即接上）。
- 已知文件過期陷阱：`Docs/04` 座標表（檔內已加警示，版面以 `Scenes/UI/VerticalUi.tscn`
  實況為準）；`ART_ASSET_MANIFEST.md` 缺列 logo.png 與 ui/ 五張新素材（帳面待補）。
- 詳見 progress 記憶與 `git log`（現況一律以 git log 為準）。
