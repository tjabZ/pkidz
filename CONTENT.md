# p-KidZ — Content Guide

> How to add and structure content for p-KidZ.
> The app is data-driven: drop images into the right folder, list them in `_labels.json`, rebuild, install.

> **Current state (2026-05-28):** content is populated with **OpenMoji** cartoon
> art (CC BY-SA 4.0) for all generic categories. 8 categories now exist —
> `djur` (50), `fordon` (25), `mat` (30), `farger`, `klader`, `kroppen`,
> `vader` (10 each), plus `familj` (7, awaiting the user's private family
> photos). **The live, authoritative item lists are each category's
> `_labels.json`** — the word tables below are the original starter set, kept
> for reference. To add OpenMoji items: find the emoji's hex codepoint and fetch
> `https://cdn.jsdelivr.net/gh/hfg-gmuend/openmoji/color/618x618/<HEX>.png`.

---

## Folder structure

All content lives in `assets/content/<category>/`:

```
assets/
  content/
    djur/
      _labels.json
      hund.png
      katt.png
      ...
    fordon/
      _labels.json
      bil.png
      ...
    mat/
      _labels.json
      ...
    familj/
      _labels.json
      bamse.png
      ...
```

---

## Naming rules

- **Folder name** — lowercase ASCII, no spaces. The Swedish display name is in `_labels.json`.
- **File name** — lowercase ASCII (`apple.png`, not `Äpple.png`). Strip Swedish chars: `å`→`a`, `ä`→`a`, `ö`→`o`. The real Swedish word lives in `_labels.json`.
- **File format** — PNG, transparent or white background preferred.
- **Image size** — ~512×512 px target, square aspect ratio works best in the 2×2 quiz grid.

ASCII-only filenames are a defensive choice — they avoid quirks in Flutter's asset bundler, pubspec globs, and any future tooling.

---

## `_labels.json` format

Each category folder has a `_labels.json` that does two things:
1. Maps ASCII filenames to the actual Swedish display word.
2. Provides the Swedish display name for the category.

Example — `assets/content/djur/_labels.json`:

```json
{
  "category_display": "Djur",
  "items": {
    "hund": "hund",
    "katt": "katt",
    "hast": "häst",
    "ko": "ko",
    "gris": "gris",
    "far": "får",
    "raev": "räv",
    "bjoern": "björn",
    "aelg": "älg",
    "uggla": "uggla"
  }
}
```

- The **key** = filename without `.png` (this is what's stored on disk)
- The **value** = the Swedish word the kid sees in the UI and must type in Stavning

If a word has no special characters, the key and value are identical.

---

## Word lists for MVP (10 per category)

Fill these in. These are starting suggestions — change freely to match what your kid will recognize.

### Djur (Animals)

| Filename       | Display word | Image notes        |
|----------------|--------------|--------------------|
| `hund.png`     | hund         |                    |
| `katt.png`     | katt         |                    |
| `hast.png`     | häst         |                    |
| `ko.png`       | ko           |                    |
| `gris.png`     | gris         |                    |
| `far.png`      | får          | sheep              |
| `raev.png`     | räv          |                    |
| `bjoern.png`   | björn        |                    |
| `aelg.png`     | älg          |                    |
| `uggla.png`    | uggla        |                    |

### Fordon (Vehicles)

| Filename       | Display word | Image notes        |
|----------------|--------------|--------------------|
| `bil.png`      | bil          |                    |
| `lastbil.png`  | lastbil      |                    |
| `buss.png`     | buss         |                    |
| `flygplan.png` | flygplan     |                    |
| `cykel.png`    | cykel        |                    |
| `taag.png`     | tåg          |                    |
| `baat.png`     | båt          |                    |
| `motorcykel.png` | motorcykel |                    |
| `helikopter.png` | helikopter |                    |
| `traktor.png`  | traktor      |                    |

### Mat (Food)

| Filename       | Display word | Image notes        |
|----------------|--------------|--------------------|
| `apple.png`    | äpple        |                    |
| `banan.png`    | banan        |                    |
| `brod.png`     | bröd         |                    |
| `mjolk.png`    | mjölk        |                    |
| `ost.png`      | ost          |                    |
| `agg.png`      | ägg          |                    |
| `kott.png`     | kött         |                    |
| `fisk.png`     | fisk         |                    |
| `potatis.png`  | potatis      |                    |
| `glass.png`    | glass        | ice cream          |

### Familj

| Filename       | Display word | Image notes              |
|----------------|--------------|--------------------------|
| `mamma.png`    | mamma        | a photo of mum, or generic |
| `pappa.png`    | pappa        |                          |
| `mormor.png`   | mormor       |                          |
| `morfar.png`   | morfar       |                          |
| `farmor.png`   | farmor       |                          |
| `farfar.png`   | farfar       |                          |
| `syskon.png`   | syskon       |                          |

---

## Sourcing tips

- **Free sources:** Pixabay, Unsplash, OpenClipart, Wikimedia Commons
- **Avoid:** Google Image Search downloads (mostly copyrighted), AI-generated for younger kids (sometimes uncanny)
- **Easy DIY:** photograph the actual item / family member on a plain background and crop square
- **Bamse / Skalman:** screenshots from old Bamse books or magazines work fine for personal use

---

## How to add a new category later

1. Create `assets/content/<new_category>/`
2. Drop in 10+ PNG images (ASCII filenames)
3. Create `_labels.json` with `category_display` and `items` map
4. Add the new folder to `pubspec.yaml` assets list
5. Rebuild the app

The home screen Bildquiz/Stavning settings will pick it up automatically.

---

## Working on this file

This is a **living document**. Edit the tables above as you decide on real words and gather images. Once final, this becomes the build-time content manifest.
