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

## 7. The autonomy contract

Applies to any session running unattended — nobody is reading your output as it
happens. Autonomy here is not a permission that was granted, it is the set of
rules below. Working outside them is not initiative, it is the failure this
whole file exists to prevent.

### 7.1 Three tiers of action

**Run alone.** Reversible, inside the current phase's scope, and ending in a
gate that exits 0. Writing and refactoring code, adding tests, running the
suites, generating assets into `art/candidates/`, acting on a human's
`revision_request`, committing to a feature branch. If it is reversible and a
machine can confirm it worked, do it and keep going.

**Prepare, do not execute.** Produce the branch, the diff and the evidence, then
stop and let a human merge. This covers anything whose blast radius outruns its
verification:

- deleting or moving more than ~200 lines in one change, or removing a file
  that something else might still reference
- the procgen verdict in `ROADMAP.md` Phase 1 — run it, measure it, write the
  recommendation with the run output attached; the deletion of 2,021 lines is
  not an unattended act
- changing dependencies, autoload registration, `project.godot`, or the shape of
  saved data
- any edit to `CANON.md`, `AGENTS.md`, `ASSETS.md` or `ROADMAP.md`

**Always stop.** Do not do these unattended under any framing:

- spending money, or first use of a paid API
- pushing to `main`, force-pushing anything, or rewriting history
- publishing: store pages, releases, anything public or outside the repo
- credentials, signing keys, store or account settings
- deciding an asset is approved, or that combat feels right — §2 and `ASSETS.md`
  are explicit that these are human judgments, and an agent grading its own
  aesthetic output is the exact defect this repo is built around
- amending canon. If canon is wrong, say so in the journal and stop

### 7.2 Batch discipline — hard rule

This machine has ~1 GB of RAM free of 15.6 GB, an integrated GPU, and the RAM is
not being upgraded. That is a constraint on the work, not a footnote.

**Never run two heavy jobs at once.** Blender, the Godot editor, and a model
session do not fit together. Art jobs run serialized with the editor closed;
`tools/blender.ps1` enforces this and refuses to start otherwise. Do not pass
`-Force` to get around a guard that is telling you the truth. Cap concurrent
subagents at **two**.

### 7.3 Stopping

**The `STOP` file.** Between every unit of work, check for a file named `STOP` at
the repo root. If it exists: finish or abandon the current unit cleanly — never
leave a half-staged commit — write the journal entry, and exit. Do not delete
the file. It is how a human stops you at a known boundary instead of killing a
terminal mid-write.

**Stop on repeated failure.** Three consecutive failures on the same unit means
stop and write it up. Do not try a fourth approach. A loop that keeps trying is
how an unattended run burns hours and money producing nothing.

**Bound the run.** Land a verified unit at least every 30 minutes of wall clock.
If you cannot, the unit is too big — split it or stop.

> A real spend cap cannot be enforced from inside the agent: there is no meter
> here to read, and a runaway loop is exactly the state least likely to check one.
> The bounds above are what an agent can actually hold itself to. A true cost
> ceiling has to come from outside — the harness or the account.

### 7.4 The run journal

Every unattended session appends one file: `runs/<UTC timestamp>.md`. It records
what was attempted, the verbatim gate output, what was refused and why, what was
left half-done, and what the next session should pick up.

This is a deliberate, narrow exception to §1's rule against files that describe
work you just did. It survives because it is a **log, not a document**: it is
never authoritative, nothing may cite it as a reason to do anything, and it
describes one run rather than the state of the project. Anything in a journal
that turns out to be true about the *project* belongs in the owning document,
and the journal entry is not the record of it.

Write the entry before exiting, including when exiting because something broke.
A run that fails and says nothing is worse than a run that never started.
