# p-KidZ — Build Plan

> This file tracks the phased build of p-KidZ.
> Update checkboxes as work completes. Each phase has a goal, tasks, and an exit criterion.
> If a phase scope expands, add tasks here. If we deviate from `SPEC.md`, update `SPEC.md` first.

**Status legend:** `[ ]` not started · `[~]` in progress · `[x]` done

---

## Phase 0 — Build environment

**Goal:** Windows dev environment ready, iPad jailbroken, CI builds reaching the iPad.

### Local dev (Windows)
- [x] Decide iOS build path → **jailbreak + GitHub Actions CI**
- [x] Install Flutter SDK on Windows (`C:\src\flutter`, on PATH, v3.44.0 stable)
- [x] Install Android Studio (`C:\Program Files\Android\Android Studio`, v2025.3.4.7)
- [~] Open Android Studio first-run wizard, install Android SDK + create AVD (user manual step)
- [x] Install VS Code + Flutter/Dart extensions (Dart-Code 3.134.0, Flutter 3.134.0)
- [ ] Verify Android device USB debugging works (using emulator instead for now)
- [ ] `flutter doctor` shows green for Android toolchain

### iPad jailbreak
- [ ] Confirm iPad model + current iOS version (must be jailbreakable by checkra1n: A7-A11 chip)
- [ ] Back up anything on the iPad worth keeping
- [ ] Turn off "Automatic Updates" on iPad (do not let iOS update post-jailbreak)
- [ ] Run checkra1n jailbreak (requires a Mac, Linux box, or Linux USB stick — Windows is harder; will research at this step)
- [ ] Install Sileo or Cydia (whichever ships with the jailbreak)
- [ ] Install AltStore **or** TrollStore on the jailbroken iPad
- [ ] Test installing a small unsigned IPA to confirm the sideload pipeline works

### CI build pipeline
- [x] Decide CI provider → **GitHub Actions** (free unlimited on public; ~200 macOS-min/mo free on private)
- [x] Create GitHub repo for the project → `github.com/tjabZ/pkidz` (public for now — see decisions log 2026-05-28)
- [x] First push to `main` triggered CI; **build succeeded** (Android APK + unsigned iOS IPA artifacts produced, 2026-05-28)
- [x] Write workflow that runs `flutter build ios --release --no-codesign` on macOS runner (`.github/workflows/build.yml`)
- [x] Workflow uploads the IPA as an artifact (also builds Android debug APK)
- [ ] Manual smoke test: download IPA, install via AltStore/TrollStore on iPad, launch

**Exit criterion:**
1. `flutter run` launches a blank Flutter app on the Android emulator from Windows.
2. A push to GitHub produces an IPA that installs and opens on the jailbroken iPad.

---

## Phase 1 — App skeleton & home shell

**Goal:** Flutter project exists; home screen with 3 tiles is navigable; theme/palette applied.

- [x] `flutter create pkidz` with `--org se.tjabz.pkidz` (bundle id confirmed: `se.tjabz.pkidz`)
- [x] Set up folder structure (`lib/{shell,modules,theme,settings}`; `content/` deferred to Phase 2)
- [x] Theme file with the Soft Scandinavian palette from `SPEC.md` §4 (`theme/palette.dart`, `theme/app_theme.dart`)
- [x] Home screen with 3 large tiles: Klocka / Bildquiz / Stavning (`shell/home_screen.dart`)
- [x] Module placeholder screens (3 routes wired via `Navigator.push`)
- [x] Home button visible in every module screen, returns to home (`shell/module_scaffold.dart`)
- [x] Orientation support (`OrientationBuilder`: column in portrait, row in landscape; no orientation lock)
- [x] Persistent settings store (`shared_preferences`; `settings/settings_controller.dart` + `SettingsScope`)
- [x] Default settings written on first launch (verified by widget test)

**Exit criterion:** Kid can tap any of the three tiles, see a blank module screen with the right title and a Home button that takes them back. ✅ (verified by `flutter analyze` clean + 3 passing widget tests covering render, navigation in/out, and first-launch defaults)

> Note: settings *screen* and parent gate are Phase 6; Phase 1 ships the settings *store* only. Home-screen gear icon deferred to Phase 6 with the parent gate.

---

## Phase 2 — Content system

**Goal:** content folders bundled, loaded at startup, ready to be consumed by modules.

- [x] Decide on `_labels.json` schema (`{category_display, items:{asciiKey: swedishWord}}` — per `CONTENT.md`)
- [x] Create `assets/content/` structure for the 4 categories (`_labels.json` for djur/fordon/mat/familj; 37 items)
- [x] Update `pubspec.yaml` with asset declarations (4 category dirs)
- [x] Write `ContentLoader` — discovers categories via `AssetManifest`, parses each `_labels.json` (`content/content_loader.dart`)
- [x] In-memory model: `ContentItem{key, displayWord, imagePath, imageAvailable}` / `Category{name, displayName, items}` / `ContentLibrary` (`content/content_models.dart`)
- [x] Smoke test: `debugPrint` of loaded categories in `main`, plus a load() integration test

**Exit criterion:** `ContentLoader` returns 4 categories with the user-supplied items, accessible from any screen. ✅ (verified by 7 passing tests incl. real-asset 4-category load; exposed app-wide via `ContentScope`)

> Images aren't bundled yet (user supplies PNGs later) — every item currently has `imageAvailable=false`. Modules (Phases 3–5) use `Category.playableItems` to skip image-less items. familj PNGs stay gitignored until the repo goes private.

---

## Phase 3 — Bildquiz module

**Goal:** working word-to-image quiz against bundled content.

- [ ] Question generator: pick category, choose 4 distinct items, mark one correct
- [ ] 2×2 grid layout (large images, word at top)
- [ ] Tap handling: correct → green flash → next question
- [ ] Tap handling: wrong → dim that tile, others stay tappable
- [ ] Endless loop until kid hits Home
- [ ] Settings: active category selection
- [ ] Visual polish (spacing, image sizing, tap targets ≥80dp)

**Exit criterion:** Kid can play Bildquiz end-to-end with their chosen category; switching categories in settings takes effect on next question.

---

## Phase 4 — Klocka module

**Goal:** working analog-clock reading game with both input methods.

- [x] Analog clock widget (12h face, hour-minute hands, custom-painted) — `modules/klocka/analog_clock.dart`
- [x] Sun/moon icon next to clock to indicate morning/afternoon (sun=AM 0–11, moon=PM 12–23)
- [x] Time generator per difficulty (1: hours · 2: +half · 3: +quarter · 4: every 5 min) — `time_generator.dart`
- [x] Multiple-choice input (4 distinct buttons in 24h format, distractors from same difficulty band)
- [x] Free-text input via two number scrollers (hours 00-23 · minutes 00-59) — `ListWheelScrollView`
- [x] Answer validation (always against 24-hour `ClockTime`)
- [x] Wrong-answer behavior (MC: dim wrong option, others tappable · scroller: red flash + retry)
- [x] Settings: difficulty · input method (in-module gear → `klocka_settings_sheet.dart`)

**Exit criterion:** Kid can play Klocka at any of the 4 difficulties, using either input method. ✅ (analyze clean + 6 Klocka tests; verified live in Chrome — clock render, MC, scrollers, settings, feedback)

> Built ahead of Phase 3 (Bildquiz) because Klocka needs no content images. Design notes: sun=AM/moon=PM is the 12→24h skill; generated hours kept to 06:00–21:59 (relatable, avoids deep-night confusion); difficulty 4 = every 5 min (readable "advanced"). Module ships its own settings sheet; parent gate still deferred to Phase 6.

---

## Phase 5 — Stavning module

**Goal:** working spelling module with custom Swedish keyboard and live validation.

- [ ] Custom big-button on-screen keyboard widget (a-ö layout, lowercase)
- [ ] Backspace key, no Shift (case-insensitive)
- [ ] Writing-line widget displaying typed letters
- [ ] Per-keystroke validation against expected letter at current position
- [ ] Wrong letter → key briefly flashes wrong color, letter is NOT committed, writing line stays at current position (no backspace needed)
- [ ] Word completion → green flash → next question
- [ ] Easy mode: faded full word above the writing line
- [ ] Medium mode: pre-filled hint letters at random positions
- [ ] Hard mode: only blank underscores
- [ ] Settings: active category · difficulty

**Exit criterion:** Kid can spell any word from the chosen category at any difficulty, with correct per-keystroke feedback.

---

## Phase 6 — Settings & parent gate

> Note: settings screens are built incrementally during phases 3-5 (each module ships its own settings panel). This phase is the polish pass.

- [ ] Settings home screen (one section per module + global)
- [ ] Parent gate (math question, e.g. "3 + 5 = ?" — fresh question each time)
- [ ] Reset-to-defaults button
- [ ] Test that all settings persist after force-close + relaunch

**Exit criterion:** Parent gate prevents kid from changing settings; all settings survive app restart.

---

## Phase 7 — Polish & first real install

**Goal:** install the app on the actual target device and observe the kid using it.

- [ ] Visual polish pass (spacing, animation, transitions)
- [ ] App icon (pastel-themed)
- [ ] Launch screen
- [ ] Test on real Android device (one full session of each module)
- [ ] Address rough edges discovered during real-device testing
- [ ] Build and install on iPad (via chosen build path from Phase 0)
- [ ] Observe one real session with the kid; note pain points
- [ ] File any pain points as new tasks under "Post-MVP" below

**Exit criterion:** Kid plays p-KidZ on their iPad for a full session and learns something.

---

## Post-MVP backlog

(Empty for now. Populate during Phase 7 observation or when ideas come up.)

- [ ] *(none yet)*

---

## Notes / decisions log

- 2026-05-27 — Initial spec locked. Soft Scandinavian palette chosen. iPad-only MVP, Android secondary.
- 2026-05-27 — Wife's Mac is pre-2018 and treated as unavailable.
- 2026-05-27 — iOS build path: **jailbreak iPad (checkra1n) + GitHub Actions CI** for builds. No Mac required locally, no Apple Developer account, no 7-day re-signing.
- 2026-05-27 — Target iPad confirmed: iPad Air 1st gen (MD785HC/A, A7 chip) on iOS 12.5.8 — fully checkra1n-compatible.
- 2026-05-27 — Familj category dropped Bamse/Skalman/Lille Skutt (copyright-friendly, generic family only). Starter content shrunk to ~37 items. User will add categories/items incrementally.
- 2026-05-27 — UI sketches phase added before code (see `sketches/index.html`).
- 2026-05-27 — Klocka simplified to **analog-only** display. Digital and "both" modes cut as redundant — analog reading is the actual skill being taught.
- 2026-05-27 — Spelling wrong-letter behavior changed: wrong taps **do not commit** to the writing line (no backspace needed). Key briefly flashes red; kid just keeps trying. Easier for a 5-7yo.
- 2026-05-27 — Correct-answer background brightened from `#DEEDD2` to `#C8E0B5` for a more rewarding visual.
- 2026-05-28 — Flutter project scaffolded (`flutter create`, org `se.tjabz.pkidz`); GitHub Actions workflow (`build.yml`) written — Android debug APK + unsigned iOS IPA. Local git repo initialized on `main`.
- 2026-05-28 — **Repo strategy:** start **public** now (free unlimited CI during active dev), with NO family photos committed. Switch to **private** later once stable/low-churn, then add real family photos. Hard rule: never commit a family photo while public (git history is permanent). Guardrail: `/assets/content/familj/` is gitignored until the switch.
- 2026-05-28 — **Phase 1 shipped.** App shell built (theme, 3-tile home, module placeholders, Home button, `shared_preferences` store). Pushed; CI green (Android APK 4m27s + unsigned iOS IPA 2m55s). Verified live in Chrome.
- 2026-05-28 — **Known CI item (not yet fixed):** GitHub Actions warns `checkout@v4`/`setup-java@v4`/`upload-artifact@v4` run on Node 20, force-upgraded to Node 24 on **2026-06-02**. Bump action majors before then to avoid breakage.
