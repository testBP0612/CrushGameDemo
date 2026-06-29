# Artist Quickstart — Magnific 產線 + Claude Code 用法

> 目的:讓你(美術同事)用 **Magnific + Claude Code** 實際把素材做出來、正確交付。
> 規格細節看 `ART_CONTRACT.md`;這裡講「怎麼做」。

## 一、先認清兩個現實(很重要)
1. **Magnific 主要是 AI 放大/重繪(upscale / reimagine),通常需要一張「輸入底圖」**,不是純文字憑空生圖。
   所以實務流程常是:先有底圖(手繪草稿 / 其他生圖工具 / 簡單塗鴉)→ 丟 Magnific 強化風格與細節。
2. **Magnific 不會輸出透明背景**;但合約要求角色是**透明 PNG**。所以**去背是另一個獨立步驟**(見下)。

## 二、單一素材的標準產線
```
(1) 取得底圖：手繪/其他生圖工具/簡單草稿 —— 一個角色、置中、側視、面向正確
		↓
(2) Magnific 強化：用 prompts/magnific_prompts.md 的樣板，統一風格/筆觸/細節
		↓
(3) 去背：得到透明背景（工具見下）
		↓
(4) 裁切 + 調尺寸：依 ART_CONTRACT 的建議尺寸，主體置中、底部對齊地面線
		↓
(5) 命名：等於 manifest 的 file_name（例 hero_idle.png）
		↓
(6) 放進 Assets/final/  ← 完成！遊戲下次匯入就會換上
```

## 三、去背 / 裁切 / 子集化的工具
- 去背:`remove.bg`、Photopea(免費網頁版 Photoshop)、Photoshop、或本機 `rembg`。
- 裁切/調尺寸:任何影像編輯器,或請 Claude Code 跑 ImageMagick 批次處理。
- (給工程的)中文字型子集化是另一回事,不用你處理。

## 四、Claude Code 在這條線能幫你什麼(以及不能)
**能:**
- 讀 `ART_CONTRACT.md` + manifest,幫你**寫/微調每個素材的 Magnific prompt**。
- 跑腳本做**批次去背 / 裁切 / 改尺寸 / 改檔名**(ImageMagick、rembg 等)。
- **對照 manifest 驗證** `Assets/final/` 的檔名/尺寸/透明對不對(交付前自檢)。
- 幫你把整理好的檔**放到正確路徑**。

**不能(要校準期待):**
- **不能直接幫你點 Magnific 網頁產圖。** Magnific 要你自己操作(除非你有 Magnific/Freepik 的 API key,才可請 Claude Code 寫腳本呼叫)。
- 不會幫你決定風格——風格是你的權力(`ART_DIRECTION_NOTES.md`)。

### 可以直接丟給 Claude Code 的指令範例
- 「讀 Art/ART_CONTRACT.md 和 Assets/ART_ASSET_MANIFEST.md,幫我為 hero_idle 寫一段 Magnific prompt」
- 「把 ~/Downloads 這張圖去背、裁成 420×420 置中、存成 Assets/final/hero_idle.png」
- 「檢查 Assets/final/ 裡的檔名/尺寸/透明背景有沒有符合 manifest,列出不合格的」

## 五、API 自動化(進階,可選)
Magnific 已併入 Freepik,有 API。若你想自動化:
1. 取得 Freepik/Magnific API key。
2. 請 Claude Code 寫一支腳本:讀 manifest → 對缺的素材呼叫 API → 去背 → 命名 → 放 final。
MVP 不需要走到這步;手動 + Claude Code 輔助就夠。

## 六、交付即完成
素材一進 `Assets/final/` 且檔名符合 manifest,就代表「可用」。工程端(Codex)在 task 08 會接入;
缺的素材遊戲會自動用 placeholder 色塊頂著,**不會壞**,所以你可以一個一個慢慢交,不必一次到位。
