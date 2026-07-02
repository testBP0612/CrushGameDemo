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

## 現況錨點

- 任務卡 01–10 完成；11（音效，D-014）待 Codex 執行；Q-005（Google 登入+雲端記分）
  與任務卡 12/13 已備妥待裁示。詳見 progress 記憶與 `git log`。
