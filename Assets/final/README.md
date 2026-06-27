# Assets/final/

**唯一正式素材入口。**

只要素材進入本資料夾，即代表它**已符合 Art Contract**（`Art/ART_CONTRACT.md`）、
已完成命名 / 裁切 / 透明背景 / 格式整理，**可被 Codex 接入**。

## 流程
1. 美術同事在外部工具確認某張圖可用。
2. 依 `Assets/ART_ASSET_MANIFEST.md` 的 `file_name` 與規格整理。
3. 直接放入本資料夾（無需額外 Git review 流程）。

## 規則
- 檔名與路徑**必須**符合 manifest，否則 Codex 不會接入。
- **Codex 只讀** `Assets/final/` 與 `Assets/placeholders/`。
- 若某素材尚未進入本資料夾，Codex 必須 fallback 到 placeholder，**不可讓遊戲壞掉**。
- 美術同事為本資料夾 owner；工程/Codex 不在此放探索稿。
