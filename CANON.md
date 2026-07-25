# CANON — Depths of the Bastard God

**This is the single source of truth for this project.** Where any other document
disagrees with this file, this file wins and the other document is wrong.

Established: 2026-07-25. Supersedes all prior scope, story, and platform statements.

---

## 0. Inherited context

Original author: **Sh4ttr** (`v4mp@void.local`). All 11 commits fall between
2025-06-03 and 2025-06-07 — a five-day burst, dormant for ~13.5 months since.

The current maintainer is **not** the original author and is working under an
explicit constraint: **the author's game concept is preserved.** Genre, tone,
perspective, systems, story, and the three-act structure are not up for
redesign. What changes is the *content budget*, which is a quantity, not an idea.

---

## 1. What the game is

A **2.5D Gothic horror action-adventure** — 2D sprites in a 3D world, orthogonal
camera at roughly 45° (Hades-style perspective). Free-exploration Metroidvania
world design inspired by *Castlevania: Symphony of the Night*. Combat is
methodical Soulslike: dodge-roll, parry, status effects.

Horror register: Gothic + cosmic + religious + body.

### NOT a roguelike

Stated verbatim in `memory-bank/corrected_art_prompt.md:10` and
`memory-bank/progress.md`. The world is **handcrafted and persistent**;
procedural generation is scoped to *specific segments* — dungeon interiors,
enemy variants, loot — layered on handcrafted bases via the tag system.

Any document claiming "the entire experience is procedurally generated" is
superseded. See §6.

---

## 2. Story canon

**Acts** (per root `story_design.md`, corroborated by `memory-bank/progress.md`
lines 128/146/163 and `memory-bank/techContext.md` lines 204-206):

| Act | Title |
|---|---|
| I | The Descending City |
| II | The Drowning Depths |
| III | The Dream Realm |

**Bosses:** The Architect · Amalgam Mother · The Bastard God
**Protagonist:** unnamed, marked by eldritch knowledge.

The alternate framing in `project_info_export/story_design.md` (acts "The
Schism" / "The Sunken Cathedral" / "The Womb of Creation", protagonist as "an
acolyte of a forgotten faith") is **not canon**. See §6.

---

## 3. Scope — the number that changed

**The 50-70 hour target is dead.** So is the "3-4 year, 10-phase" plan.

Reasoning, on record: no shipped Metroidvania reaches that length. *Symphony of
the Night* ~12h. *Blasphemous* ~13h. *Ender Lilies* ~12h. *Hollow Knight* ~27h
main (~60h completionist) — and that was three people, three years, Kickstarter
funding. The stated inspiration for this project runs twelve hours.

### What replaces it

**v1.0 ships Act I only — The Descending City. Target 3-5 hours.**

Acts II and III remain canon and remain the roadmap. They ship as post-launch
content, not as launch scope. The three-act structure the author designed is
preserved intact; only the delivery is staged.

This is the reconciliation: the author's game is built as designed, at a length
that one person can actually finish.

### v1.0 content budget

- One act: The Descending City
- One playable class (of the three designed)
- 8-12 enemy types
- 3 bosses, ending with The Architect
- One ending path
- Sanity system active; Blood Echoes economy active
- Mutations, companions, Black Market, remaining classes and endings: **post-v1.0**

---

## 4. Platform

**Android + PC (Steam).** Landscape orientation on both.

Android remains a first-class target — the existing 2,550-line touch input layer
is the project's strongest asset and is not sacrificed. PC is added because
Godot exports to it at near-zero cost and it changes the commercial ceiling by
an order of magnitude.

Input: touch (Android) and gamepad + keyboard/mouse (PC). The input abstraction
in `input_manager.gd` is the foundation for both.

Any document stating "Android ONLY" or "portrait orientation" is superseded.

---

## 5. Dimension

**2.5D / 3D.** Decided. `CharacterBody3D` is the player base.

Consequence: the 2D branch is removed, not archived. See the deletion manifest
in `DELETIONS.md`.

---

## 6. Superseded documents

These contain statements that contradict this canon. They are scheduled for
removal or correction — see `DELETIONS.md`.

| Document | Conflict |
|---|---|
| `project_info_export/prd.md` | calls the game a roguelike; "entire experience is procedurally generated" |
| `project_info_export/story_design.md` | alternate acts, alternate protagonist |
| `roadmap.md` | "Current Status: Pre-Development", unfilled `[Current Date]`, all Phase 0/1 unchecked, no mention of 3D |
| `design.md` (root) | describes the pre-3D concept; no mention of 2.5D or Hades perspective |
| `.taskmaster/tasks/task_001.txt` | specifies portrait orientation, marked done |
| `README.md` | declares `.taskmaster/tasks/tasks.json` canonical; that file does not exist |

---

## 7. Known integrity defects (facts, not opinions)

Verified by direct code audit 2026-07-25. These are the state of the repo as
inherited, not new findings to be re-litigated.

1. **~2,026 lines of procedural generation never execute.** `scripts/hybrid/*.gd`
   declares no `class_name`. The five class names (`HandcraftedManager`,
   `ProceduralManager`, `SafetyChecker`, `TagSystem`, `TemplateSystem`) are
   declared *only* in `scripts/systems/*.gd`, which are 2-4 function stubs
   returning hardcoded `{"name": "Placeholder ..."}` dictionaries. The
   `HybridGenerator` autoload instantiates by class name, so Godot resolves to
   the stubs. Nothing loads `scripts/hybrid/` by path either.
2. **All cross-autoload signal wiring is commented out** behind
   `# TODO: Fix signal connections after autoload initialization` in
   `hybrid_generator.gd`.
3. **No playable loop.** `main_menu.tscn` is the project's `run/main_scene`; its
   "Start Game" button prints `"TODO: Implement game start"` and loads nothing.
4. **A second, more complete main menu** (`scenes/main/main.tscn`) exists with a
   working `start_new_game()` — and is unreachable, because it is not the
   `main_scene`.
5. `scenes/test_input.tscn` references `res://scripts/ui/touch_button.gd`, which
   does not exist in the repo.
6. `sanity_manager.gd:151` emits `"sanity_corruption_reset"`, a signal not
   declared in `event_bus.gd`.
7. No test framework, no CI, no art assets (only Godot's default `icon.png`), no
   audio.

**The orphaned procgen is not to be resurrected until there is a running game to
put it in.** It is code that has never executed — a hypothesis, not an asset.
Re-enabling it is cheap (delete stubs, add `class_name`), which is a reason to
*test* it early, not a reason to bet on it.

---

## 8. The only metric that counts

This project has produced ~8,700 lines of code and **zero seconds of gameplay.**

Until v1.0, progress is measured in **seconds of verified, running, replayable
gameplay** — not lines, not tasks closed, not percent complete. Work that does
not move that number is out of scope.

First milestone: `main_scene` boots → a 3D player walks in a generated space →
an automated test asserts it, headless.

---

## 9. Amendment rule

This document may be **edited**. New documents that restate scope, story, or
platform may **not** be created. If this canon is wrong, fix it here — do not
write a second opinion elsewhere. That failure mode is what produced the state
described in §6 and §7.
