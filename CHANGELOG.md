# Changelog

All notable changes to this project are recorded here. The history below follows the repository from the first commit; related doc-only or merge commits are summarized together.

### Fixed

- **Saved post text (`.txt`)** — decode HTML/XML character references (`&gt;`, `&lt;`, `&amp;`, etc.) and strip WordprocessingML fragments (`<w:…>`, `</w:…>`) from post and comment bodies in `text_writer.py`.

---

## 2026-03-29

### Added

- **`--ongoing-live-monitor-no-prompt`** — with `--ongoing-live-monitor`, continue polling after a live ends without prompting to keep monitoring.
- **Mux / remux progress** — Rich progress bar (or spinner when duration is unknown) while FFmpeg muxes or remuxes; uses **ffprobe** when available for duration.

### Changed

- **Interactive menu** — Archive and Actions as separate Tab/→ sections; clearer spacing on smaller terminals; ongoing layout fixes.
- **README** and **`config.yaml.template`** — ongoing-live tooling (Streamlink, ffprobe, flags), prerequisites, and configuration notes.

### Fixed

- **macOS** — keyboard handling in interactive menus.
- **HDR streams** — download/mux path adjustments for HDR content.

### Other

- Extract creation date from image URL when saving **profile pictures** (community contribution, merged via PR #1).
- **`official_channels`** filename template updates.

---

## 2026-03-28

### Added

- **Initial Weverse archiver** — CLI entry point, community selection, filters, artist/channel/archive actions, DRM VOD downloads (N_m3u8DL-RE / Widevine), live VOD flow, **ongoing (on-air) live** recording, download history, configurable paths and templates.

### Changed

- **Entry script** renamed from `wv-archive.py` to **`archiverse.py`** (legacy file removed after merges).
- **macOS** — early keyboard-handling improvements for menus.

### Project

- **`config.yaml.template`** and **README** — first-pass setup and usage documentation.
