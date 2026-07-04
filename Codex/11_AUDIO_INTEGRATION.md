# 任務 11：音效接入（BGM + SFX 播放能力）

> **前置條件（未滿足不得執行）**：`Docs/OPEN_QUESTIONS.md` Q-004 已有人類回答，且 `Docs/DECISIONS.md` 已寫入 **D-014**。若本卡內容與 D-014 定案有出入，以 D-014 為準並回報。

## 目標
把 task 06 預留的 `AudioService` 空殼升級為真正可播音的服務：接入 BGM 與既有 9 個 SFX 事件的播放能力，全程資料驅動、缺檔靜音不崩、正確處理 H5 音訊解鎖。**不改任何玩法/數值/狀態流程/版面。**

## 必讀文件
`AGENTS.md`、`Docs/DECISIONS.md`（D-008 → D-014）、`Docs/SFX_TODO.md`（事件清單與呼叫點）、`Docs/07_H5_EXPORT_SPEC.md`（音訊解鎖）、`Docs/06_DATA_SCHEMA.md`。

## 範圍
1. **`Data/audio.json`（新增）**，schema 如下（定案後由規劃端同步至 `Docs/06`）：
   ```json
   {
	 "bgm": { "file": "bgm_main.mp3", "loop": true, "volume_db": -8.0 },
	 "sfx_volume_db": -4.0,
	 "sfx_events": {
	   "button_click": "sfx_button_click.ogg",
	   "attack_hit": "sfx_attack_hit.ogg"
	 }
   }
   ```
   - `sfx_events` 只列**已有音檔**的事件；未列出的 event_id 一律靜音略過。
   - 事件 ID 全集見 `Docs/SFX_TODO.md`，不得新增未在該清單的事件 ID（要加先開 Q）。
2. **`Assets/final/audio/`（新增資料夾）**：唯一正式音訊入口。
   - 將工作區的 `Assets/FishAlleyQuest.mp3` 於 Godot 內改名移入為 `Assets/final/audio/bgm_main.mp3`（在編輯器內搬移以正確處理 `.import`）。
   - SFX 音檔命名 `sfx_<event_id>.ogg`（或 mp3/wav），可分批補齊，本卡不要求備齊。
3. **`Scripts/services/audio_service.gd`（空殼→實作）**：
   - 啟動時讀 `Data`（autoload）的 audio 設定，預載可用音檔；檔案不存在→記 warning、該事件靜音，**不得報錯中斷**。
   - `play_sfx(event_id)`：查映射→播放；未映射/缺檔/未解鎖→靜默略過。**方法簽名不變**，既有呼叫點（`game_controller.gd`、`button_feedback.gd`）不需修改。
   - 新增 `play_bgm()` / `stop_all()` 實作；BGM 依設定 loop。
   - SFX 用小型 `AudioStreamPlayer` 池（同時多聲不互斷即可，不必過度設計）。
4. **H5 音訊解鎖**：首次使用者互動（任一點擊/觸碰）時解鎖音訊並開始 BGM；解鎖前所有播放呼叫靜默不報錯。桌面編輯器內直接可播（無解鎖問題）。

## 不做
- 不做靜音鈕/音量滑桿等任何 UI（Future；不動版面、不觸 D-006 不變量）。
- 不改玩法、數值、狀態機、結算、節點結構。
- 不自行生成/尋找 SFX 音檔；缺檔就是靜音（fallback 原則同 D-004 精神）。
- 不在腳本寫死檔名/音量/loop（一律讀 `Data/audio.json`，AGENTS 鐵則 6）。

## 實作要求（關鍵）
1. **音訊錯誤不得影響遊戲流程**：任何載入/播放失敗只能 warning + 靜音，狀態機照走（同 task 06 效果容錯原則）。
2. **刪掉 `Data/audio.json` 或整個 `audio/` 資料夾，遊戲仍可完整跑完一局**（回到 D-008 的無聲狀態）。
3. 服務層歸位 `Scripts/services/`，不把播放邏輯散進 core/ui。
4. 完成後更新 `Docs/SFX_TODO.md`：標注各事件「已接檔 / 待補音檔」。

## 驗收方式
- 編輯器內：BGM 開播並 loop；已映射的 SFX 事件在對應時機發聲。
- 改 `audio.json` 的 `volume_db` / 移除某事件映射 → 重啟後生效（證明資料驅動）。
- 移除某音檔實體 → 該事件靜音、遊戲不崩、可跑完整局。
- 刪除整個 `Data/audio.json` → 全程靜音、遊戲不崩。
- H5 export：載入後**首次互動前無聲且無 console 錯誤**，首次點擊後 BGM 響起；跑完一局 SFX 正常。
- 對照 `Codex/VALIDATION_CHECKLIST.md`「里程碑 — 任務 11」逐項自驗。

## 完成後必須回報
依 `AGENTS.md` 完成回報格式（列出實際接入的音檔清單、缺檔事件、H5 驗證方式）。
