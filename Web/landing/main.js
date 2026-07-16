"use strict";

document.documentElement.classList.add("js");

const GAME_URL = "https://crushgamedemo-bloop.web.app/";
const SHARE_URL = "https://crushgamedemo-bloop.web.app/intro/";
const DESKTOP_QUERY = "(min-width: 1024px)";
const REDUCED_MOTION_QUERY = "(prefers-reduced-motion: reduce)";
const SPRITE_FRAME_INTERVAL_MS = 250;
const SPRITE_CANVAS_SIZE = 512;
const REVEALED_MONSTER_COUNT = 3;

const DATA_PATHS = {
  monsters: "assets/monsters.json",
  text: "assets/ui_text.json",
  balance: "assets/game_balance.json"
};

const state = {
  text: {},
  balance: {},
  monsters: [],
  desktopMedia: window.matchMedia(DESKTOP_QUERY),
  reducedMotion: window.matchMedia(REDUCED_MOTION_QUERY)
};

function cleanTemplate(value) {
  return String(value || "")
    .replace(/\s*\{[^}]+\}\s*/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

async function fetchJson(path) {
  const response = await fetch(path, { cache: "no-cache" });
  if (!response.ok) {
    throw new Error(`Unable to load ${path}: ${response.status}`);
  }
  return response.json();
}

function bindText() {
  document.querySelectorAll("[data-text-key]").forEach((element) => {
    const key = element.dataset.textKey;
    const resolved = cleanTemplate(state.text[key]);
    if (resolved) {
      element.textContent = resolved;
    }
  });
}

function formatMultiplier(value) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    return "-";
  }
  return number.toFixed(2).replace(/\.00$/, "").replace(/(\.\d)0$/, "$1");
}

function renderMultiplierTrack() {
  const track = document.querySelector("#multiplier-track");
  const curve = Array.isArray(state.balance.multiplier_curve)
    ? state.balance.multiplier_curve
    : [];

  track.replaceChildren();
  curve.forEach((entry) => {
    const item = document.createElement("li");
    const stage = document.createElement("span");
    const multiplier = document.createElement("strong");
    stage.textContent = `Stage ${entry.stage}`;
    multiplier.textContent = `x${formatMultiplier(entry.multiplier)}`;
    item.append(stage, multiplier);
    track.append(item);
  });
}

function createDangerIcons(level) {
  const fragment = document.createDocumentFragment();
  for (let index = 0; index < level; index += 1) {
    const star = document.createElement("img");
    star.src = "assets/ui/risk_star.png";
    star.width = 24;
    star.height = 24;
    star.alt = "";
    fragment.append(star);
  }
  return fragment;
}

function renderDangerScale() {
  const container = document.querySelector("#danger-stars");
  const maxLevel = Number(state.balance.danger_display?.max_level || 0);
  container.replaceChildren();
  if (maxLevel <= 0) {
    container.hidden = true;
    return;
  }
  container.hidden = false;
  container.setAttribute("aria-label", `危險度最高 ${maxLevel} 星`);
  container.append(createDangerIcons(maxLevel));
}

function dangerLevelForStage(stage) {
  const successEntry = state.balance.success_rate_curve?.find(
    (entry) => Number(entry.stage) === Number(stage)
  );
  const levels = state.balance.danger_display?.levels;
  if (!successEntry || !Array.isArray(levels)) {
    return 0;
  }

  const match = levels.find(
    (entry) => Number(successEntry.success_rate) >= Number(entry.min_success_rate)
  );
  return match ? Number(match.level) : 0;
}

function setMonsterFallback(card, monster, name) {
  stopMonsterAnimation(card);
  card.classList.remove("is-animated");
  card.classList.add("is-fallback");
  const fallback = card.querySelector(".monster-fallback");
  fallback.style.backgroundColor = "var(--hot-pink)";
  fallback.textContent = name;
}

function createMysteryMonsterCard(monster) {
  const stageNumber = Number(monster.stage);
  const card = document.createElement("article");
  card.className = "monster-card monster-card--mystery";
  card.dataset.stage = String(stageNumber);
  card.dataset.mystery = "true";
  card.setAttribute("aria-label", `第 ${stageNumber} 關未知街頭怪物，進遊戲揭曉`);

  const stage = document.createElement("span");
  stage.className = "monster-stage";
  stage.textContent = String(stageNumber).padStart(2, "0");
  stage.setAttribute("aria-hidden", "true");

  const visual = document.createElement("div");
  visual.className = "monster-visual monster-visual--mystery";

  const mysteryIcon = document.createElement("img");
  mysteryIcon.className = "monster-mystery-icon";
  mysteryIcon.src = "assets/mystery_encounter.png";
  mysteryIcon.width = SPRITE_CANVAS_SIZE;
  mysteryIcon.height = SPRITE_CANVAS_SIZE;
  mysteryIcon.loading = "lazy";
  mysteryIcon.decoding = "async";
  mysteryIcon.alt = "";
  mysteryIcon.setAttribute("aria-hidden", "true");
  visual.append(mysteryIcon);

  const nameplate = document.createElement("h3");
  nameplate.className = "monster-nameplate";
  nameplate.textContent = "？？？";

  const meta = document.createElement("div");
  meta.className = "monster-meta monster-meta--mystery";
  const revealLabel = document.createElement("span");
  revealLabel.textContent = "進遊戲揭曉";
  meta.append(revealLabel);

  card.append(stage, visual, nameplate, meta);
  return card;
}

function createMonsterCard(monster) {
  if (Number(monster.stage) > REVEALED_MONSTER_COUNT) {
    return createMysteryMonsterCard(monster);
  }

  const name = state.text[monster.name_key] || monster.id;
  const level = dangerLevelForStage(monster.stage);
  const card = document.createElement("article");
  card.className = "monster-card";
  card.dataset.assetId = monster.art_asset_id;
  card.dataset.stage = String(monster.stage);

  const stage = document.createElement("span");
  stage.className = "monster-stage";
  stage.textContent = String(monster.stage).padStart(2, "0");
  stage.setAttribute("aria-hidden", "true");

  const visual = document.createElement("div");
  visual.className = "monster-visual";

  const preview = document.createElement("img");
  preview.className = "monster-preview";
  preview.src = `assets/boss${monster.stage}_card.png`;
  preview.width = SPRITE_CANVAS_SIZE;
  preview.height = SPRITE_CANVAS_SIZE;
  preview.loading = "lazy";
  preview.decoding = "async";
  preview.alt = `${name} 怪物圖`;

  const canvas = document.createElement("canvas");
  canvas.className = "monster-canvas";
  canvas.width = SPRITE_CANVAS_SIZE;
  canvas.height = SPRITE_CANVAS_SIZE;
  canvas.setAttribute("role", "img");
  canvas.setAttribute("aria-label", `${name} 待機動畫`);

  const fallback = document.createElement("span");
  fallback.className = "monster-fallback";

  preview.addEventListener("error", () => setMonsterFallback(card, monster, name));
  visual.append(preview, canvas, fallback);

  const nameplate = document.createElement("h3");
  nameplate.className = "monster-nameplate";
  nameplate.textContent = name;

  const meta = document.createElement("div");
  meta.className = "monster-meta";
  const stageLabel = document.createElement("span");
  stageLabel.textContent = `Stage ${monster.stage}`;
  const danger = document.createElement("span");
  danger.className = "monster-danger";
  danger.setAttribute("aria-label", `危險度 ${level} 星`);
  danger.append(createDangerIcons(level));
  meta.append(stageLabel, danger);

  card.append(stage, visual, nameplate, meta);
  return card;
}

function drawFrame(card, frameIndex) {
  const animation = card._monsterAnimation;
  if (!animation) {
    return;
  }

  const frameName = animation.frameNames[frameIndex];
  const frameData = animation.frames[frameName];
  if (!frameData || frameData.rotated) {
    throw new Error(`Unsupported frame data: ${frameName}`);
  }

  const frame = frameData.frame;
  const canvas = card.querySelector(".monster-canvas");
  const context = canvas.getContext("2d");
  const scale = Math.min(canvas.width / frame.w, canvas.height / frame.h);
  const width = frame.w * scale;
  const height = frame.h * scale;
  const x = (canvas.width - width) / 2;
  const y = (canvas.height - height) / 2;

  context.clearRect(0, 0, canvas.width, canvas.height);
  context.drawImage(
    animation.sheet,
    frame.x,
    frame.y,
    frame.w,
    frame.h,
    x,
    y,
    width,
    height
  );
}

function stopMonsterAnimation(card) {
  const animation = card._monsterAnimation;
  if (animation?.requestId) {
    cancelAnimationFrame(animation.requestId);
    animation.requestId = 0;
  }
}

function startMonsterAnimation(card) {
  const animation = card._monsterAnimation;
  if (!animation || animation.requestId || state.reducedMotion.matches) {
    return;
  }

  const tick = (timestamp) => {
    if (!animation.lastFrameAt || timestamp - animation.lastFrameAt >= SPRITE_FRAME_INTERVAL_MS) {
      animation.frameIndex = (animation.frameIndex + 1) % animation.frameNames.length;
      drawFrame(card, animation.frameIndex);
      animation.lastFrameAt = timestamp;
    }
    animation.requestId = requestAnimationFrame(tick);
  };

  animation.requestId = requestAnimationFrame(tick);
}

function loadImage(path) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.decoding = "async";
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error(`Unable to load ${path}`));
    image.src = path;
  });
}

async function loadMonsterAnimation(card, monster, name) {
  if (card.dataset.animationState) {
    if (card.dataset.animationState === "ready") {
      startMonsterAnimation(card);
    }
    return;
  }

  card.dataset.animationState = "loading";
  const basePath = `assets/boss/${monster.art_asset_id}`;

  try {
    const frameJson = await fetchJson(`${basePath}.json`);
    const sheet = await loadImage(`${basePath}.png`);
    const animationNames = frameJson.meta?.animations?.[monster.art_asset_id];
    const frameNames = Array.isArray(animationNames) && animationNames.length
      ? animationNames
      : Object.keys(frameJson.frames || {});

    if (!frameNames.length) {
      throw new Error(`No frames found for ${monster.art_asset_id}`);
    }

    card._monsterAnimation = {
      sheet,
      frames: frameJson.frames,
      frameNames,
      frameIndex: 0,
      lastFrameAt: 0,
      requestId: 0
    };
    drawFrame(card, 0);
    card.dataset.animationState = "ready";
    card.classList.add("is-animated");
    startMonsterAnimation(card);
  } catch (error) {
    console.warn(error.message);
    card.dataset.animationState = "failed";
    setMonsterFallback(card, monster, name);
  }
}

function observeMonsterCards(cards, monstersByStage) {
  if (!("IntersectionObserver" in window)) {
    cards.forEach((card) => card.classList.add("is-visible"));
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      const card = entry.target;
      const monster = monstersByStage.get(Number(card.dataset.stage));
      const name = state.text[monster?.name_key] || monster?.id || "怪物";
      if (entry.isIntersecting) {
        card.classList.add("is-visible");
        if (state.desktopMedia.matches && !state.reducedMotion.matches && monster && card.dataset.mystery !== "true") {
          loadMonsterAnimation(card, monster, name);
        }
      } else {
        stopMonsterAnimation(card);
      }
    });
  }, { rootMargin: "128px 0px" });

  cards.forEach((card) => observer.observe(card));
}

function renderBestiary() {
  const strip = document.querySelector("#monster-strip");
  const status = document.querySelector("#data-status");
  const monsters = [...state.monsters].sort((left, right) => left.stage - right.stage);
  const monstersByStage = new Map(monsters.map((monster) => [Number(monster.stage), monster]));
  const fragment = document.createDocumentFragment();
  const cards = monsters.map((monster) => {
    const card = createMonsterCard(monster);
    fragment.append(card);
    return card;
  });

  strip.replaceChildren(fragment);
  strip.tabIndex = 0;
  const hiddenCount = Math.max(0, monsters.length - REVEALED_MONSTER_COUNT);
  status.textContent = monsters.length
    ? `已公開 ${Math.min(REVEALED_MONSTER_COUNT, monsters.length)} 隻，還有 ${hiddenCount} 次未知遭遇等你解鎖`
    : "街頭情報暫時無法載入";
  setupMonsterScrollCue(strip);
  observeMonsterCards(cards, monstersByStage);
}

function setupMonsterScrollCue(strip) {
  const shell = document.querySelector("#monster-strip-shell");
  const updateCue = () => {
    shell.classList.toggle("has-scrolled", strip.scrollLeft > 32);
  };
  strip.addEventListener("scroll", updateCue, { passive: true });
  updateCue();
}

function emitConversionEvent(action) {
  window.dispatchEvent(new CustomEvent("landing:conversion", {
    detail: { action, timestamp: Date.now() }
  }));
}

function setupConversionEvents() {
  document.addEventListener("click", (event) => {
    const trigger = event.target.closest("[data-conversion]");
    if (trigger) {
      emitConversionEvent(trigger.dataset.conversion);
    }
  });
}

async function copyShareUrl() {
  if (navigator.clipboard?.writeText) {
    await navigator.clipboard.writeText(SHARE_URL);
    return;
  }

  const textarea = document.createElement("textarea");
  textarea.value = SHARE_URL;
  textarea.setAttribute("readonly", "");
  textarea.style.position = "fixed";
  textarea.style.opacity = "0";
  document.body.append(textarea);
  textarea.select();
  const copied = document.execCommand("copy");
  textarea.remove();
  if (!copied) {
    throw new Error("Clipboard unavailable");
  }
}

function setupShareButtons() {
  const shareData = {
    title: "Meow準快跑",
    text: "落袋為安，還是再冒一次險？一起來挑戰街頭怪物！",
    url: SHARE_URL
  };

  document.querySelectorAll("[data-share-game]").forEach((button) => {
    const status = document.querySelector(`#${button.dataset.shareStatus}`);
    button.addEventListener("click", async () => {
      status.textContent = "";
      button.disabled = true;
      try {
        if (navigator.share) {
          await navigator.share(shareData);
          status.textContent = "分享完成";
          emitConversionEvent("share_native");
        } else {
          await copyShareUrl();
          status.textContent = "介紹頁網址已複製";
          emitConversionEvent("share_copy");
        }
      } catch (error) {
        if (error.name !== "AbortError") {
          try {
            await copyShareUrl();
            status.textContent = "介紹頁網址已複製";
            emitConversionEvent("share_copy");
          } catch {
            status.textContent = `分享網址：${SHARE_URL}`;
          }
        }
      } finally {
        button.disabled = false;
      }
    });
  });
}

function setupGameEmbed() {
  const stage = document.querySelector("#game-stage");
  const poster = document.querySelector("#load-game");
  let frame = null;

  const removeFrame = () => {
    if (frame) {
      frame.remove();
      frame = null;
    }
    poster.hidden = false;
  };

  const createFrame = () => {
    if (!state.desktopMedia.matches || frame) {
      return;
    }
    frame = document.createElement("iframe");
    frame.src = GAME_URL;
    frame.title = "Meow準快跑遊戲";
    frame.allow = "autoplay; fullscreen";
    frame.allowFullscreen = true;
    poster.hidden = true;
    stage.append(frame);
  };

  poster.addEventListener("click", createFrame);
  const handleBreakpoint = (event) => {
    if (!event.matches) {
      removeFrame();
    }
  };

  if (state.desktopMedia.addEventListener) {
    state.desktopMedia.addEventListener("change", handleBreakpoint);
  } else {
    state.desktopMedia.addListener(handleBreakpoint);
  }
}

function setupMobileStickyCta() {
  const cta = document.querySelector("#mobile-sticky-cta");
  const trackedElements = [
    document.querySelector(".hero"),
    document.querySelector(".mobile-preview-card"),
    document.querySelector(".site-footer")
  ];
  const intersections = new Map(trackedElements.map((element) => {
    const rect = element.getBoundingClientRect();
    const isInitiallyVisible = rect.bottom > 0 && rect.top < window.innerHeight;
    return [element, isInitiallyVisible];
  }));

  const updateVisibility = () => {
    const overlapsTrackedContent = trackedElements.some((element) => intersections.get(element));
    const visible = !state.desktopMedia.matches && !overlapsTrackedContent;
    cta.classList.toggle("is-visible", visible);
    cta.setAttribute("aria-hidden", String(!visible));
    cta.tabIndex = visible ? 0 : -1;
  };

  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => intersections.set(entry.target, entry.isIntersecting));
      updateVisibility();
    }, { threshold: 0.08 });
    trackedElements.forEach((element) => observer.observe(element));
  }

  if (state.desktopMedia.addEventListener) {
    state.desktopMedia.addEventListener("change", updateVisibility);
  } else {
    state.desktopMedia.addListener(updateVisibility);
  }
  updateVisibility();
}

async function initialize() {
  setupConversionEvents();
  setupShareButtons();
  setupGameEmbed();
  setupMobileStickyCta();
  document.querySelector("#copyright-year").textContent = String(new Date().getFullYear());

  try {
    const [monstersData, textData, balanceData] = await Promise.all([
      fetchJson(DATA_PATHS.monsters),
      fetchJson(DATA_PATHS.text),
      fetchJson(DATA_PATHS.balance)
    ]);
    state.monsters = Array.isArray(monstersData.monsters) ? monstersData.monsters : [];
    state.text = textData.text || {};
    state.balance = balanceData || {};
    bindText();
    renderMultiplierTrack();
    renderDangerScale();
    renderBestiary();
  } catch (error) {
    console.error(error);
    document.querySelector("#data-status").textContent = "街頭情報暫時無法載入，遊戲仍可正常開啟。";
  }
}

initialize();
