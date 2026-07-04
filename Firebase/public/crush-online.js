// crush-online.js — Godot ↔ Firebase 橋接（D-015 / Docs/08）
// 載入順序：config.js（提供 window.__FIREBASE_CONFIG__）→ 本檔（module）。
// 缺 config / SDK 載入失敗時：window.CrushOnline.ready 維持 false，
// Godot 端偵測後留在本機模式（fallback 契約，Docs/08 §五）。
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut, onAuthStateChanged }
  from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";
import { getFirestore, doc, setDoc, getDoc, serverTimestamp,
         collection, query, where, orderBy, limit, getDocs, getCountFromServer }
  from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

const SAVE_DEBOUNCE_MS = 800;

const state = {
  ready: false,
  app: null, auth: null, db: null, user: null,
  godotAuthCb: null, godotLoadCb: null,
  saveTimer: null, pendingSave: null,
};

function emitAuth() {
  if (!state.godotAuthCb) return;
  state.godotAuthCb(JSON.stringify({
    signed_in: !!state.user,
    uid: state.user ? state.user.uid : "",
    display_name: state.user ? (state.user.displayName || "") : "",
  }));
}

async function flushSave() {
  state.saveTimer = null;
  if (!state.user || !state.pendingSave) return;
  const payload = state.pendingSave;
  state.pendingSave = null;
  try {
    await setDoc(doc(state.db, "users", state.user.uid), {
      best_payout: payload.best,
      balance: payload.balance,
      display_name: state.user.displayName || "",
      updated_at: serverTimestamp(),
    });
  } catch (e) {
    console.warn("[CrushOnline] save failed:", e.code || e.message);
  }
}

window.CrushOnline = {
  get ready() { return state.ready; },

  // Godot 以 JavaScriptBridge.create_callback 傳入兩個回呼
  bindCallbacks(authCb, loadCb) {
    state.godotAuthCb = authCb;
    state.godotLoadCb = loadCb;
    emitAuth(); // 綁定當下立即回報現況（可能已透過持久化 session 登入）
  },

  signIn() {
    if (!state.ready) return;
    signInWithPopup(state.auth, new GoogleAuthProvider())
      .catch((e) => console.warn("[CrushOnline] signIn failed:", e.code || e.message));
  },

  signOut() {
    if (!state.ready) return;
    signOut(state.auth).catch((e) => console.warn("[CrushOnline] signOut failed:", e.code));
  },

  // 高頻呼叫安全：JS 端 debounce 合併，僅落最後一筆（Docs/08：結算級頻率）
  save(best, balance) {
    if (!state.user) return;
    state.pendingSave = { best: Number(best) || 0, balance: Number(balance) || 0 };
    if (state.saveTimer) clearTimeout(state.saveTimer);
    state.saveTimer = setTimeout(flushSave, SAVE_DEBOUNCE_MS);
  },

  async requestLoad() {
    if (!state.user || !state.godotLoadCb) return;
    try {
      const snap = await getDoc(doc(state.db, "users", state.user.uid));
      const d = snap.exists() ? snap.data() : null;
      state.godotLoadCb(JSON.stringify({
        found: !!d,
        best_payout: d ? (d.best_payout || 0) : 0,
        balance: d ? (d.balance || 0) : 0,
      }));
    } catch (e) {
      console.warn("[CrushOnline] load failed:", e.code || e.message);
      state.godotLoadCb(JSON.stringify({ found: false, best_payout: 0, balance: 0, error: true }));
    }
  },

  // --- D-016 排行榜（Phase 2）：每次呼叫帶入自己的一次性回呼，避免與上面
  // 的 auth/load 常駐回呼互相干擾，也天然支援多個排行榜請求並存。 ---

  submitLeaderboard(best, name) {
    if (!state.user) return;
    (async () => {
      try {
        const ref = doc(state.db, "leaderboard", state.user.uid);
        const snap = await getDoc(ref);
        const prevBest = snap.exists() ? (snap.data().best_payout || 0) : -1;
        if (Number(best) <= prevBest) return; // 單調遞增：client 端也守一次，rules 是最終底線
        await setDoc(ref, {
          display_name: name || (state.user.displayName || ""),
          best_payout: Number(best) || 0,
          updated_at: serverTimestamp(),
        });
      } catch (e) {
        console.warn("[CrushOnline] submitLeaderboard failed:", e.code || e.message);
      }
    })();
  },

  fetchLeaderboard(topN, cb) {
    if (!state.ready) { cb(JSON.stringify({ rows: [], error: true })); return; }
    (async () => {
      try {
        const q = query(collection(state.db, "leaderboard"), orderBy("best_payout", "desc"), limit(topN));
        const snap = await getDocs(q);
        const rows = [];
        let rank = 1;
        snap.forEach((d) => {
          const data = d.data();
          rows.push({
            rank: rank++,
            uid: d.id,
            display_name: data.display_name || "",
            best_payout: data.best_payout || 0,
          });
        });
        cb(JSON.stringify({ rows }));
      } catch (e) {
        console.warn("[CrushOnline] fetchLeaderboard failed:", e.code || e.message);
        cb(JSON.stringify({ rows: [], error: true }));
      }
    })();
  },

  fetchRankFor(payout, cb) {
    if (!state.ready) { cb(JSON.stringify({ rank: 0, beaten_percent: 0, error: true })); return; }
    (async () => {
      try {
        const col = collection(state.db, "leaderboard");
        const [higherSnap, lowerSnap, totalSnap] = await Promise.all([
          getCountFromServer(query(col, where("best_payout", ">", payout))),
          getCountFromServer(query(col, where("best_payout", "<", payout))),
          getCountFromServer(query(col)),
        ]);
        const higher = higherSnap.data().count;
        const lower = lowerSnap.data().count;
        const total = totalSnap.data().count;
        cb(JSON.stringify({
          rank: higher + 1,
          beaten_percent: total > 0 ? Math.floor((lower * 100) / total) : 0,
        }));
      } catch (e) {
        console.warn("[CrushOnline] fetchRankFor failed:", e.code || e.message);
        cb(JSON.stringify({ rank: 0, beaten_percent: 0, error: true }));
      }
    })();
  },
};

try {
  const cfg = window.__FIREBASE_CONFIG__;
  if (!cfg) throw new Error("missing __FIREBASE_CONFIG__ (config.js not loaded?)");
  state.app = initializeApp(cfg);
  state.auth = getAuth(state.app);
  state.db = getFirestore(state.app);
  onAuthStateChanged(state.auth, (user) => { state.user = user; emitAuth(); });
  state.ready = true;
  console.log("[CrushOnline] bridge ready");
} catch (e) {
  console.warn("[CrushOnline] init failed, game stays local-only:", e.message);
}
