# MindQuest

An ADHD-friendly RPG productivity app for teens and parents. Tasks become quests — a world map,
turn-based battles, skill trees, parent-assigned tasks, and rewards turn everyday to-dos into a game.

> **Native iOS app (SwiftUI).** This is the live product. Older alternate ports and a web prototype
> have been archived (see *Repo layout*).

## Tech

- **SwiftUI**, deployment target **iOS 15.0**, Swift 5.0, **Xcode 16+**
- On-device persistence: **UserDefaults** (JSON), behind a `DataProvider` protocol (migration-ready)
- No backend in v1 — fully self-contained on device
- Bundle ID: `com.mocha.MindLabsQuest2024`

## Run it

1. Open `MindLabsQuest.xcodeproj` in Xcode 16+.
2. Select the **iPhone 16 (iOS 18.5)** simulator.
3. Build & run (⌘R). New `.swift` files are auto-included (filesystem-synchronized project group).

Tests live in `MindLabsQuestTests/` and `MindLabsQuestUITests/`.

## Repo layout

```
MindLabsQuest/            SwiftUI source (Models, Content, Managers, Services, Views, Protocols)
MindLabsQuest.xcodeproj   Xcode project
Assets.xcassets/          app icon + shared assets
MindLabsQuestTests/       unit tests
MindLabsQuestUITests/     UI tests
docs/                     DESIGN_DOC.md (V2 design) + map_prototype.html (interactive world map)
mindquest-pm-agent/       separate Python PM-automation tool
```

Stale artifacts (alternate ports, web/docker prototype, old scaffold docs) are preserved on the
`archive/pre-cleanup-2026-06-17` branch.

## Docs

- [`docs/DESIGN_DOC.md`](docs/DESIGN_DOC.md) — V2 architecture: world map, parent tasks, asset/VFX framework
- [`docs/map_prototype.html`](docs/map_prototype.html) — interactive world-map prototype

## Working in this repo

See [`CLAUDE.md`](CLAUDE.md) for the agent/dev brief. This project follows the shared
[MindLab Best Practices](https://github.com/MochaS29/best-practices) (read on session init), with
native-iOS deviations documented in `CLAUDE.md`.
