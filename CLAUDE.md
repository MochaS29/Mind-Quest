# MindQuest (MindLabsQuest) — CLAUDE.md

> Operational brief for Claude Code / any new terminal session in this repo.

## Best practices (read on init)

This project follows the shared **MindLab Best Practices**. On starting a session, read them:

1. Read the local copy at `~/Development/best-practices/` — start with `README.md`, then `standards/`.
2. If that path doesn't exist, pull it first:
   `git clone https://github.com/MochaS29/best-practices ~/Development/best-practices`
   (or run `~/Development/best-practices/scripts/sync-best-practices.sh` to refresh it).

These standards govern monorepo layout (`apps/` + `platforms/`), Linear task tracking with image
capture, local Supabase Docker testing with seed data + a reserved port block (see `PORTS.md`),
`develop`/`production` branching + Vercel deploys, documentation, the agent workflow (`/cpg`, `/pup`,
`/verify-ui` + guardrail hooks), payments, stack gotchas, and the terminal status line.
**Instructions below override the shared standards where they conflict** — note any deliberate
deviation with a one-line reason (see *Deviations* at the bottom).

---

## What this is

MindQuest — an ADHD-friendly RPG productivity/quest app for teens + parents. Tasks become quests;
a world map, battles, skill trees, parent-assigned tasks, and rewards drive engagement.

## Stack

- **Native iOS, SwiftUI** — the live app. Deployment target **iOS 15.0**, Swift 5.0, **Xcode 16+**.
- **Persistence:** UserDefaults with JSON encoding (SwiftData migration deferred). A `DataProvider`
  protocol + `UserDefaultsDataProvider` abstracts storage (Firebase-migration prep).
- **No backend** in v1 — no Supabase, no web server, no payments SDK. Self-contained on-device.
- Bundle ID: `com.mocha.MindLabsQuest2024`.

## Layout (this repo is multi-artifact — the iOS app is the live one)

```
MindLabsQuest.xcodeproj      Xcode project (auto-syncs files via PBXFileSystemSynchronizedRootGroup)
MindLabsQuest/               SwiftUI source — Models/ Content/ Managers/ Services/ Views/ Protocols/
MindLabsQuestTests/ UITests/ test targets
DESIGN_DOC.md                V2 design (world map + parent tasks + assets) — Notion-ready
MINDQUEST_README.md          project readme
map_prototype.html           interactive world-map prototype
MindLabsQuestSwiftUI/, MindLabsQuestAndroid/, MindQuestApp/  older / alternate ports (not the live app)
mindquest-pm-agent/          PM automation agent (separate Python tool)
docker/, docker-compose*.yml  for the pm-agent / web prototype, NOT the iOS app
```

Architecture detail (managers, content databases, story system) is large — see `DESIGN_DOC.md` and
the `MindLabsQuest/` source groups rather than duplicating it here.

## Build / run

- Open `MindLabsQuest.xcodeproj` in Xcode 16+.
- **Simulator:** iPhone 16, OS 18.5.
- New `.swift` files are auto-included (filesystem-synchronized group) — no manual project edits.
- Tests: `MindLabsQuestTests` / `MindLabsQuestUITests` (the precommit-sanity hook recognises
  `xcodebuild` / `swift test`).

## iOS gotchas (hard-won)

- `.italic()` requires iOS 16+ — avoid (target is 15.0).
- `for…in` loops don't work in ViewBuilder on iOS 15 — use `ForEach`.
- `Color(hex:)` lives in `MindLabsTheme.swift` (non-failable) — don't add a duplicate.
- Color token is `Color.mindLabsCard` (NOT `mindLabsCardBackground`).
- CoreData entity is `CDPlaceholder` (renamed from `Item` to avoid clashing with the game `Item` struct).
- `EnergyManager.spendEnergy()` returns `Bool` (not `useEnergy()`).

## Task tracking

Linear, per standard 02 — issues + image capture. For UI work, **screenshot the simulator** for each
key step and attach to the Linear issue (the `/verify-ui` skill is browser-only; for native, capture
the simulator manually). Execution-class labels + Agent-brief block apply.

## Git

- Single branch **`main`** (remote `MochaS29/Mind-Quest`). Distribution is the App Store, not Vercel.
- `/cpg` works (commit + push current branch). `/pup` does **not** apply (no Vercel/Supabase prod to
  promote/verify) — App Store releases go through Xcode/App Store Connect.

## Deviations from best practices (with reasons)

- **No `apps/` + `platforms/` monorepo** — single native iOS app in a historically multi-artifact repo.
- **No Supabase / local Docker testing / seed data / port block** — v1 has no backend; persistence is
  on-device UserDefaults. (`PORTS.md` base not needed.)
- **No `develop`/`production` split, no Vercel deploy, no Stripe** — single `main`; ships via App Store;
  monetization is (planned) StoreKit IAP, not Stripe. The `block-production-write` hook is **not**
  installed (it would gate `main`, the only working branch).
