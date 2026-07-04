# 任務 16：排行榜 UI 四接觸點（Codex 執行：生成素材 + 擺位 + 目視驗證）

> **前置**：任務 15 已完成回報（服務接點就緒）。
> **視覺目標**：`Art/references/ui_target_lb_betting.png` / `ui_target_lb_decision.png` /
> `ui_target_lb_cashout.png` / `ui_target_lb_defeat.png`（人類 2026-07-04 提供的四張 mockup，
> 需先由人類放入該路徑）。mockup 是**視覺方向**，版面仍以 `Docs/04` 座標契約與不變量為準。

## 目標
依 D-016 在四個畫面加入排行榜回饋，單局流程與既有面板結構不變。

## 四個接觸點（對照 mockup）
1. **下注畫面**：金幣膠囊旁小型「🏆 排行榜」入口鈕 → 開排行榜面板。
2. **決策畫面（撤退/續戰）**：按鈕上方一條窄橫幅：「目前最佳：第 N 名」或「若現在撤退約第 N 名」（用 `request_rank_for(current_payout)`；文案 key 見下）。
3. **撤退成功結算面板**（增列，不改結算邏輯）：目前排名、超過 X% 玩家、個人最高紀錄、「查看排行榜 >」入口。
4. **失敗結算面板**：本次最深進度 N/10、超過 X% 玩家（用死前 payout）、目前最佳第 N 名、「查看排行榜 >」入口。

## 排行榜面板（共用）
- skin_panel 9-slice 質感、Top 10 列表（名次/暱稱/分數）、本人列高亮（ui_skin 參數，不硬編色值）、關閉鈕。
- 讀取中 `lb_loading`；空資料 `lb_empty`。
- 只能從下注畫面與結算畫面開啟；戰鬥進行中不可開。

## 素材生成（D-012 產線：母檔 + runtime 48px，入 manifest）
- 必要：`icon_trophy`（獎盃）。
- 建議（mockup 有出現，缺圖不阻塞）：`icon_medal`（獎牌）、`icon_flag`（進度旗）、`icon_players`（超越百分比）。
- 風格同既有貼紙：奶白+深藍厚描邊、貼紙感。

## `ui_text.json` 新 key（禁止寫死；`{x}` 變數照既有慣例）
`lb_button`、`lb_title`、`lb_loading`、`lb_empty`、`lb_close`、`lb_current_best_rank`、
`lb_cashout_rank_hint`、`lb_result_rank`、`lb_result_beaten`、`lb_result_personal_best`、
`lb_defeat_depth`、`lb_view_entry`。

## 不做
- 不改狀態機/結算數值/流程；不做分頁、好友、每日挑戰。
- 不等 Firebase（資料來自任務 15 的 Mock 服務）。

## 驗收
- 四接觸點與 mockup 方向一致；版面不變量不破壞（**Godot 目視 + H5 實機皆截圖**，通用檢查：涉素材必做 H5 實機）。
- 改 `leaderboard_mock.json` → 各畫面數字全部跟著變。
- 改 `ui_text.json` → 文案跟著變。
- 戰鬥中無法開面板；整局流程與現狀一致。
- 對照 `VALIDATION_CHECKLIST.md`「里程碑 — 任務 16」。

## 完成後必須回報
依 `AGENTS.md` 格式，附四接觸點截圖（編輯器 + H5）。
