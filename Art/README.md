# Art/ — 美術同事 START HERE

> 你是美術同事,clone 完這個 repo 看這份就對了。本資料夾收所有**美術文件**(人看的);
> 實際素材檔放在 `Assets/`(Godot 讀取,路徑固定,別動)。
>
> 🤖 **用 Claude 輔助**:在這個資料夾裡跟 Claude 對話即可——它會自動套用 `Art/AGENTS.md` 的「美術助理」角色
> (幫你寫 Magnific prompt、去背裁切、對照規格驗證、放進 final)。直接把問題丟給它就行。

## 你的任務一句話
依規格,用 Magnific(或任何工具)做出 **MVP 必要素材**,整理好放進 `Assets/final/`,遊戲就會自動換上正式美術。
**風格你決定**,但**接入規格(檔名/尺寸/透明/面向)必須照合約**。

## 讀這個順序
1. **本檔**(你在這)
2. [`ARTIST_QUICKSTART.md`](ARTIST_QUICKSTART.md) — 實際產線怎麼跑、Claude Code 怎麼幫你
3. [`ART_CONTRACT.md`](ART_CONTRACT.md) 🔒 — **不可違反**的接入規格(檔名/路徑/透明/面向/尺寸/匯入)
3.5. [`ART_SPEC_SHEET.md`](ART_SPEC_SHEET.md) — **精確尺寸 + pivot + 製程清單**(照這做最省事;含 UI 尺寸參考)
4. [`../Assets/ART_ASSET_MANIFEST.md`](../Assets/ART_ASSET_MANIFEST.md) — 要做哪些素材的清單(檔名/規格逐項)
5. [`ART_DIRECTION_NOTES.md`](ART_DIRECTION_NOTES.md) — 風格筆記(**你主筆**,可自由改)
6. [`references/ui_mockup_battle.png`](references/ui_mockup_battle.png) — 整體視覺目標
7. [`prompts/magnific_prompts.md`](prompts/magnific_prompts.md) — 每個素材的 Magnific prompt 起手樣板

## MVP 你只要先做這些(前 5 隻怪 + 主角 + 背景)
- 主角:`hero_idle` / `hero_attack` / `hero_hurt` / `hero_defeat`
- 怪物:`monster_001_idle` ~ `monster_005_idle`
- 背景:`background_battle_001`
- (可選)`game_logo`
> 完整規格與 fallback 見 manifest。6~10 隻怪物缺圖沒關係,遊戲會用色塊頂著。

## 鐵則(最常踩雷的點)
- 檔名**必須**等於 manifest 的 `file_name`(全小寫、底線),否則不會被接入。
- 角色要**透明背景 PNG**;**主角面向右、怪物面向左**。
- 完成的素材**直接放 `Assets/final/`**——進到那裡就代表「可用」。候選稿/失敗稿**不要進 repo**。
- 想改合約(`ART_CONTRACT.md` 是 🔒 locked)→ 不要直接改,去 `../Docs/OPEN_QUESTIONS.md` 開 `Q-ART-XXX`。

## 交付前自我檢查
見 `ART_DIRECTION_NOTES.md` 末段 checklist,或請 Claude Code 幫你對照 manifest 驗證(見 Quickstart)。
