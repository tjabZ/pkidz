# p-KidZ

A small, offline-first Flutter learning app for one Swedish-speaking child
(age 5–7, early reader). Three practice modules, no scores, no network:

- **Klocka** — read an analog clock, answer in 24-hour time
- **Bildquiz** — pick the image that matches a Swedish word
- **Stavning** — spell the word shown by an image, on a custom Swedish keyboard

The app is data-driven: content is bundled image folders, and each folder's
`_labels.json` maps ASCII filenames to the Swedish display word.

## Status

| Phase | What | State |
|-------|------|-------|
| 0 | Build env, CI, iPad jailbreak | CI ✅ · jailbreak pending (manual) |
| 1 | App skeleton & home shell | ✅ |
| 2 | Content system | ✅ |
| 3 | Bildquiz | ✅ |
| 4 | Klocka | ✅ |
| 5 | Stavning | ✅ |
| 6 | Settings, parental PIN & screen-time lock | ✅ |
| 7 | Polish & first real install | 7a polish ✅ · 7b install pending (jailbreak) |
| 8 | Stavning capitals + Klocka 12-hour mode | ✅ |
| 9 | Klocka "set the clock" (digital→analog) | ✅ |

See `PLAN.md` for the live build plan and decisions log.

## Documentation

- **`SPEC.md`** — what we're building (the locked contract)
- **`PLAN.md`** — phased build plan, checkboxes, and decisions log
- **`CONTENT.md`** — how to add/structure content

## Tech

- Flutter (Dart), iOS 12+ minimum, fully offline
- State via `shared_preferences` (last-used settings only)
- iOS builds via GitHub Actions (unsigned IPA for a jailbroken iPad); Android
  debug APK also built in CI. Day-to-day dev on Windows.

## Running locally

```bash
flutter pub get
flutter run                 # Android emulator / device
flutter run -d chrome       # quick UI check in a browser
flutter analyze && flutter test
```

## Content

Generic categories use **OpenMoji** art (CC BY-SA 4.0); see
`assets/content/IMAGE_CREDITS.md`. The `familj` category is reserved for the
user's private family photos and stays out of the public repo. To add items:
drop PNGs into `assets/content/<category>/`, list them in that folder's
`_labels.json`, and declare the folder in `pubspec.yaml`.
