# AGENTS.md — operating rules for agent sessions on DotBG

Read `CANON.md` first, every session. It is the single source of truth.

---

## 1. Document rules

- **`CANON.md` wins.** If any file in this repo contradicts it, the other file
  is wrong. Do not "reconcile" by splitting the difference — fix the wrong file
  or delete it.
- **Do not create new design, scope, story, or PRD documents.** Edit `CANON.md`.
  This repo already died once of document proliferation: two PRDs, two story
  bibles, two main menus, two player controllers. Contradictory specs produce
  contradictory code at machine speed.
- Files listed as superseded in `CANON.md` §6 are **not** valid context. Do not
  read them for direction; do not cite them; do not restore behavior from them.

## 2. Verification rules

The defining defect of this codebase is that **code was written and never run.**
~2,026 lines of procedural generation have executed zero times. All autoload
signal wiring sits commented out. The main menu's start button loads nothing.

Therefore:

- **Never claim something works without running it.** Not "should work", not
  "implemented" — run it and paste the output.
- A task is not done when the code is written. It is done when a test or a
  running build demonstrates the behavior.
- Prefer automated verification (headless run, asserted test) over screenshots.
  A screenshot judged by the same model that wrote the code is the model grading
  its own work.
- If you cannot run it, say so explicitly and mark the work unverified.

## 3. Scope rules

- v1.0 is **Act I only, 3-5 hours**. See `CANON.md` §3.
- Do not implement Acts II/III, mutations, companions, the Black Market,
  additional classes, or additional endings. They are canon but post-v1.0.
- **Do not resurrect `scripts/hybrid/`** until a playable loop exists.
- No new systems until the existing ones run.

## 4. Code rules

- Player base is `CharacterBody3D`. The 2D branch is removed — do not reintroduce
  `CharacterBody2D` player code.
- Platform targets are Android (touch) and PC (gamepad + KBM), both landscape.
  Route all input through `input_manager.gd`; do not read raw input events in
  gameplay scripts.
- One `main_scene`. One main menu. If you find a second of anything structural,
  that is a bug — report it.
- Before adding a `class_name`, search the repo for that name first. The
  shadowing defect in `CANON.md` §7.1 was caused by duplicate class declarations.

## 5. Asset rules

`ASSETS.md` is binding. The short version:

- Generated output goes to `art/candidates/` only — never straight to
  `art/approved/` or `dotbg/assets/`.
- Every asset gets its provenance sidecar written in the same step that creates
  it. An asset without provenance cannot be regenerated and is deleted on sight.
- Verify before reporting: the file exists, its hash is unique among siblings,
  and the generator's output count incremented. **Generation tools fail
  silently and have lied about success in this project** — never pass along a
  tool's self-report as evidence.
- Never overwrite an asset filename. A revision is a new variant.
- Only a human marks an asset `approved`.

## 6. Session hygiene

- Agents lose coherence around the 40-minute mark and roughly 30k lines of
  context. Work in small, verifiable units and land them.
- Update `CANON.md` §7 when an integrity defect is actually fixed. Do not mark
  it fixed until §2 is satisfied.
