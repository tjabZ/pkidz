# p-KidZ — Specification

> Locked specification for the p-KidZ children's learning app.
> This is the single source of truth for **what** we're building.
> Implementation details (the **how**) live in `PLAN.md`.

---

## 1. Overview

p-KidZ is a lightweight, offline-first educational app for one specific user: my Swedish-speaking child, age 5-7, an early reader.

Three learning modules:
1. **Klocka** — learning to read a clock
2. **Bildquiz** — pick the image matching a Swedish word
3. **Stavning** — type the word shown by an image

The system is data-driven: new content is added by dropping image files into folders. Filenames define the correct answers.

---

## 2. Audience & Devices

- **User:** one child, age 5-7, Swedish, early reader
- **Primary device (MVP):** iPad Air 1 / Mini 2-3 or newer (iOS 12+)
- **Secondary (post-MVP):** Android tablet/phone
- **Orientation:** both portrait and landscape, rotates with device
- **Connectivity:** fully offline; no network calls

---

## 3. Tech Stack

- **Framework:** Flutter (Dart)
- **iOS minimum:** 12.0
- **Content delivery:** bundled in the app at build time
- **Persistence:** local key-value store (last-used settings only)
- **Audio:** none in MVP (OS sounds only)

### Build environment
- Daily development on Windows, tested on Android emulator + physical Android device
- iOS builds run on cloud CI (GitHub Actions or Codemagic free tier) — no local Mac needed
- iPad is jailbroken (checkra1n) so unsigned IPAs install permanently — no Apple Developer account, no 7-day re-signing
- The wife's pre-2018 Mac is treated as unavailable

---

## 4. Visual Design — Soft Scandinavian

| Role        | Hex       | Use                                 |
|-------------|-----------|-------------------------------------|
| Background  | `#F6F1E8` | App background (warm cream)         |
| Primary     | `#A7C5BD` | Primary buttons, key elements (sage)|
| Secondary   | `#88A8C0` | Secondary buttons (muted blue)      |
| Accent      | `#E8B4A0` | Highlights, call-to-action (peach)  |
| Text        | `#2F3E46` | Body and heading text (deep slate)  |
| Correct     | `#B5D3A8` | Right-answer border (soft green)    |
| Correct BG  | `#C8E0B5` | Right-answer fill (stronger green)  |
| Wrong       | `#E8A3A3` | Wrong-answer feedback (soft rose)   |

- Rounded corners, generous spacing, large tap targets (kid-sized)
- Clean and calm — not screaming colors
- Typography: friendly sans-serif, large readable sizes

---

## 5. App Shell

### Home screen
- Three large tiles: **Klocka**, **Bildquiz**, **Stavning**
- Tap to enter a module
- Small gear icon (visible but parent-gated)

### Parent gate
- Triggered when the gear is long-pressed (or short-tapped — TBD during design)
- Simple math question (e.g. "3 + 5 = ?") — easy for parent, blocks a 5-7yo
- On success → settings screen

### Settings (parent-gated)
- Per-module configuration (difficulty, display mode, input mode, category)
- All settings persist between launches
- Reset to defaults option

### Module screens
- Endless practice — no rounds, no score, no end screen
- Always-visible Home button (returns to home screen)
- Wrong-answer feedback: option dims, kid retries until correct
- Right-answer feedback: subtle green highlight, brief delay, next question

### Persistence
- Last-used settings (difficulty, mode, category) saved between launches
- App always opens to the home screen (not resume-into-session)

---

## 6. Module: Klocka (Clock)

Teach the child to read an analog clock.

### Display
- **Analog only** — 12-hour clock face with all 1-12 numbers, hour + minute hands
- Digital and "both" modes were considered but cut as redundant — analog is what the kid actually needs to learn

### AM/PM handling
- Swedish does not use AM/PM
- A small sun/moon icon next to the clock indicates morning vs afternoon, so the kid can produce a 24-hour answer from a 12-hour face

### Difficulty levels
1. Full hours only (3:00, 4:00, ...)
2. + half hours (3:30, 4:30, ...)
3. + quarter hours (3:15, 3:45, ...)
4. Random minutes (advanced)

### Answer methods (configurable)
- **Multiple choice** — 4 time options as tappable buttons (in 24-hour format, e.g. `15:30`)
- **Free text** — two large number scrollers (hours 00-23, minutes 00-59)

The kid **always** enters their answer in 24-hour digital format (e.g. `15:30`).

### Multiple-choice distractor rules
- One correct answer + 3 plausible distractors drawn from the same difficulty band
- Distractors must be unique and not equal to the correct answer

### Feedback
- Correct: green highlight, brief pause, next question
- Wrong: that option dims, others remain tappable, kid retries

---

## 7. Module: Bildquiz (Image Quiz)

Word-to-image recognition.

### Direction (MVP)
- Word displayed at top → kid taps the matching image
- Reverse direction (image → word) is post-MVP

### Layout
- Word in large text at top
- 2×2 grid of 4 large images below

### Content selection
- Settings: which category (`/content/<category>/`) the questions are drawn from
- Each question: 4 random images from the chosen category, one is the "target"
- Target word is shown as text; correct answer = matching image

### Feedback
- Correct image tapped → green highlight, next question
- Wrong image tapped → that image dims, others remain tappable, kid retries

---

## 8. Module: Stavning (Spelling)

Spell the word shown by an image.

### Content source
- Reuses the **same** image folders as Bildquiz (no separate spelling content)

### Gameplay
- Image displayed prominently at top
- Below: a writing line where the kid types the word
- Custom big-button on-screen Swedish keyboard at bottom (includes å, ä, ö)
- Only lowercase keys (case-insensitive matching means no Shift needed)

### Difficulty levels
- **Easy** — the correct word appears faded above the writing line (tracing/copy)
- **Medium** — some letters of the word are pre-filled as hints (e.g. `b _ m _ e` for "bamse")
- **Hard** — only blank underscores: `_ _ _ _ _`

### Live validation
- Every keystroke is checked against the expected letter at that position
- Correct letter → committed to the writing line, kid continues to next position
- Wrong letter → **does not commit**. The pressed key briefly flashes `#E8A3A3` (wrong) on the keyboard, the writing line stays unchanged at the current position. Kid just keeps trying — no backspace needed.
- Case-insensitive: `bamse`, `Bamse`, `BAMSE` all accepted

### Word completion
- When the typed word matches the filename (case-insensitive) → green flash, next question

---

## 9. Content System

### Folder structure
```
/content
    /djur          (animals)
        hund.png
        katt.png
        ...
    /fordon        (vehicles)
        bil.png
        flygplan.png
        ...
    /mat           (food)
        apple.png  (lowercase ASCII filename — see naming rules)
        brod.png
        ...
    /familj        (family — private photos)
        mamma.png
        pappa.png
        ...
```

Additional categories added during build: `farger` (colors), `klader`
(clothes), `kroppen` (body), `vader` (weather). New categories drop in the same
way — folder + `_labels.json` + add to `pubspec.yaml`.

### Naming rules
- Folder name = category display name (e.g. `djur` displayed as "Djur")
- File name (without `.png`) = the answer the kid must produce
- Filenames are lowercase ASCII; å→a, ä→a, ö→o for filesystem safety
- A separate metadata mechanism (TBD in `CONTENT.md`) maps ASCII filenames back to display words with Swedish characters

### Image source & specs
- **Generic categories** (everything except `familj`) use **OpenMoji** emoji art
  — consistent cartoon style, free (CC BY-SA 4.0), 618×618 PNG. This replaced the
  original "user supplies all photos" plan: cohesive look, no sourcing burden.
- **`familj`** uses the user's own **family photos** (private; excluded from the
  public repo, see PLAN.md decisions log).
- PNG, roughly square; downscaled for grid display.

### Content (current)
8 categories, ~145 items (grows over time by dropping in more):
- `djur` 50 · `fordon` 25 · `mat` 30 · `farger` 10 · `klader` 10 · `kroppen` 10
  · `vader` 10 · `familj` 7 (awaiting user photos)
- The live item lists live in each category's `_labels.json` (the source of
  truth). `CONTENT.md` describes the system and the original starter words.

---

## 10. Settings (Parent-Gated)

Reachable from the home screen via the parent gate.

Per-module configurable:
- **Klocka:** difficulty (1-4), answer method (MC/free text)
- **Bildquiz:** active category
- **Stavning:** active category, difficulty (easy/medium/hard)

Global:
- Reset to defaults

---

## 11. Out of Scope (MVP)

These are deliberately deferred:
- Audio (sound effects, voice-over, pronunciation)
- Progress tracking, streaks, scores, rewards
- Multiple-child profiles
- Image → word direction in Bildquiz
- Handwriting / drawing input
- AI-generated content
- Parent dashboard
- Localization (Swedish only)
- Push to App Store / Play Store
- Network sync of content

---

## 12. Future Ideas (Captured, Not Built)

Listed here so we don't lose them:
- Spoken pronunciation per word
- Per-child profile selection on launch
- Lightweight stats trail (streaks, weekly chart)
- Sticker/reward inventory
- More categories (numbers, colors, opposites)
- Sentence-building module
- Reverse direction in Bildquiz
- Configurable rounds with score screen as alternative to endless mode

---

## 13. Open Items

- Final word list per category — to be filled into `CONTENT.md` by user
- Font choice — to be picked during shell phase
- Bundle id (default `se.tjabz.pkidz`) — confirm before first build

---

*Anything not in this document is not in the MVP. Changes require updating this file.*
