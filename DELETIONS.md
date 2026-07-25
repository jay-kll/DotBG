# Deletion manifest — canonization pass

Proposed, **not executed.** Nothing in this file has been deleted yet.

Companion to `CANON.md`. Rationale for each entry is the canon section it
enforces.

---

## Tier 1 — code: the losing 2D branch and dead scenes

`CANON.md` §5 decides 2.5D/3D. The 2D branch is the loser and is removed rather
than archived, because agents read archives and will reintroduce it.

| Path | Lines | Why |
|---|---|---|
| `dotbg/scripts/characters/player/player.gd` | 322 | 2D `CharacterBody2D` controller — losing branch |
| `dotbg/scenes/characters/player/player.tscn` | — | scene for the above |
| `dotbg/scenes/levels/test_level.tscn` | — | 2D platformer test level; only consumer of the 2D player |
| `dotbg/main.tscn` | — | bare empty `Node2D`, no script, referenced by nothing |
| `dotbg/scenes/test_input.tscn` | — | references `res://scripts/ui/touch_button.gd`, which does not exist |

Retained: `player_3d.gd`, `player_3d.tscn`, `scenes/test_3d_complete.tscn`.

---

## Tier 2 — documents that contradict canon and carry no unique design content

| Path | Why |
|---|---|
| `project_info_export/prd.md` | calls the game a roguelike; "the entire experience is procedurally generated" — directly contradicts `CANON.md` §1 |
| `project_info_export/story_design.md` | alternate acts (The Schism / Sunken Cathedral / Womb of Creation) and alternate protagonist — contradicts `CANON.md` §2 |
| `roadmap.md` | "Current Status: Pre-Development", `Last Updated: [Current Date]` never filled, every Phase 0/1 checkbox unchecked including work that is done, no mention of 3D. Superseded by `CANON.md` §3 and the 48 files in `.taskmaster/tasks/` |

---

## Tier 3 — DO NOT DELETE

These look like duplicates on a fast read. They are not. **They carry the
original author's design content, which `CANON.md` §0 protects.**

| Path | Why it stays |
|---|---|
| `story_design.md` (root) | This *is* the canonical story bible per `CANON.md` §2 — its acts are the ones `memory-bank/` cites |
| `design.md` (root) | 447 lines of the author's systems design: Blood Echoes, Mutations, classes, weapon/armor/artifact tiers, endings. It omits the 3D pivot — an omission, not a contradiction. Needs a header pointing to `CANON.md`, not deletion |
| `project_info_export/feature_description.md` | **Agrees** with canon: "Handcrafted World... Procedural generation is focused on specific gameplay segments." It is the file the failed `d8f0787` correction got right |
| `project_info_export/executive_summary.md` | Needs review before any action — external-facing summary, may hold framing worth keeping |
| `project_info_export/ui_style_description.md` | Needs review — art/UI direction, no known conflict with canon |
| `memory-bank/**` | The 3D-pivot canon layer. Source of `CANON.md` §1, §2, §5 |

---

## Not a deletion — a merge decision that needs a human

**Two main menus exist and neither is usable as-is.**

- `dotbg/scenes/main_menu.tscn` — *is* the project's `run/main_scene`, but its
  "Start Game" button only prints `"TODO: Implement game start"`.
- `dotbg/scenes/main/main.tscn` + `main.gd` — more complete, has a working
  `start_new_game()` that resets `GameManager`/`PlayerStats` state — but it is
  **not** the `main_scene`, so it is unreachable in play, and it instances
  `test_level.tscn`, which Tier 1 removes.

Neither can simply be deleted. The working `start_new_game()` logic from
`main/main.gd` has to be carried over, and its 2D level reference replaced with
a 3D scene, before the redundant menu is removed. Flagging rather than guessing.

---

## Execution note

Deletions are staged on branch `chore/canonization` and are recoverable from git
history. They are still deletions — confirm before running.
