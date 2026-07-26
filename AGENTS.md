# AGENTS.md — operating rules for agent sessions on DotBG

Read `CANON.md` first, every session. It is the single source of truth.

---

## 1. Document rules

**Exactly four documents bind you**, and `CANON.md`'s *Document authority*
section is the registry that says so:

| Read it for | Document |
|---|---|
| what the game is | `CANON.md` |
| how to behave in this repo | `AGENTS.md` (this file) |
| how to handle any file you produce | `ASSETS.md` |
| what to build next and how to prove it | `ROADMAP.md` |

Everything else — `README.md`, `design.md`, `story_design.md`, `memory-bank/`,
`.taskmaster/`, `project_info_export/` — is **source material with zero
authority.** Read it for the author's intent; never take direction from it.

Where things live:

| Path | What it is |
|---|---|
| `dotbg/` | **the Godot 4 project.** All engine code, scenes and tests. Godot's `res://` is this directory |
| `dotbg/tests/` | the headless suite (§2) |
| `art/` | art references and candidates, governed by `ASSETS.md` — not imported by the engine |
| `tools/` | repo scripts (test runner) |
| `memory-bank/`, `project_info_export/`, `.taskmaster/` | source material, zero authority |

- **`CANON.md` wins** over any file that contradicts it. Do not "reconcile" by
  splitting the difference — fix the wrong file or delete it.
- **Do not create a new binding document.** If you believe one is needed, it
  requires a row in the canon's registry table added in the same commit.
  An unregistered document has no authority and will be deleted. In practice
  the answer is almost always: edit the document that already owns the question.
- **Never write a document that describes work you just did.** Put the outcome
  in the commit message and in the owning document. Files like
  `PLAN.md` / `SUMMARY.md` / `CHANGES.md` read as current three months later and
  are how this repo accumulated contradictions the first time.
- Files listed as superseded in `CANON.md` §11 are not valid context.

## 2. Verification rules

The defining defect of this codebase is that **code was written and never run.**
2,021 lines of procedural generation have executed zero times. All cross-autoload
signal wiring still sits commented out. See `CANON.md` §9.

Therefore:

- **Never claim something works without running it.** Not "should work", not
  "implemented" — run it and paste the output.
- A task is not done when the code is written. It is done when a test or a
  running build demonstrates the behavior.
- Prefer automated verification (headless run, asserted test) over screenshots.
  A screenshot judged by the same model that wrote the code is the model grading
  its own work.
- If you cannot run it, say so explicitly and mark the work unverified.

### The harness — run this

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1
```

Exits 0 on pass, non-zero on failure, and prints which Godot binary it used.
Currently 19 checks: seven autoloads, run-state reset, the 3D scene loading, the
player simulated and standing, and the camera orthogonal at a measured 45°.

**Do not invoke a bare `godot`.** It is not on PATH on this machine (installed
via winget, which creates no shim), so the bare command fails with *command not
found* — the runner resolves the binary via `$env:GODOT` → PATH → winget. If you
need Godot for something the runner does not cover, resolve it the same way.
Current version: **4.7.1-stable**.

Every phase gate in `ROADMAP.md` extends this suite. A gate is a command that
exits 0 or 1, never a judgment.

## 3. Scope rules

- v1.0 is **Act I only, 3-5 hours**. See `CANON.md` §8.
- Do not implement Acts II/III, mutations, companions, the Black Market,
  additional classes, or additional endings. They are canon but post-v1.0.
- **`scripts/hybrid/`: test it, do not build on it.** Running the orphaned
  procgen against real input to reach a keep-or-delete verdict is Phase 1 work
  and is wanted now — it is cheap and has executed zero times. What is forbidden
  is *adopting* it: wiring it into scenes, generating content with it, or
  writing anything that depends on it, before a playable loop exists. Verdict
  now, dependency later.
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
  shadowing defect in `CANON.md` §9, open defect 1, was caused by duplicate
  class declarations.

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
- Move a defect from Open to Closed in `CANON.md` §9 when it is actually fixed.
  Do not mark it fixed until §2 is satisfied.
- **Leave the repo readable by a session that has none of your context.** Before
  you finish, a cold reader going `CANON.md` → `AGENTS.md` → `ROADMAP.md` must
  end up knowing what the game is, how to behave, and what to do next. If your
  work invalidated a line in one of those three, fix the line — do not write a
  note about it somewhere else.
