# Deletion manifest — canonization pass

Proposed, **not executed.** Nothing here has been deleted yet.

Revision 2 — updated after `CANON.md` merged Visions 2 and 3. **The merge shrank
this list.** Several `project_info_export/` files that looked like duplicates are
now canon sources.

---

## Tier 1 — code: the losing 2D branch and dead scenes

`CANON.md` §1 fixes the game as 2D animated sprites over 3D Blender environments
under a Hades-style orthogonal camera. The pure-2D branch is the loser, and is
removed rather than archived because agents read archives and will reintroduce it.

| Path | Lines | Why |
|---|---|---|
| `dotbg/scripts/characters/player/player.gd` | 322 | 2D `CharacterBody2D` controller — losing branch |
| `dotbg/scenes/characters/player/player.tscn` | — | scene for the above |
| `dotbg/scenes/levels/test_level.tscn` | — | 2D platformer test level; only consumer of the 2D player |
| `dotbg/main.tscn` | — | bare empty `Node2D`, no script, referenced by nothing |
| `dotbg/scenes/test_input.tscn` | — | references `res://scripts/ui/touch_button.gd`, which does not exist |

Retained: `player_3d.gd`, `player_3d.tscn`, `scenes/test_3d_complete.tscn`.

---

## Tier 2 — documents

| Path | Action | Why |
|---|---|---|
| `roadmap.md` | **delete** | "Current Status: Pre-Development", `Last Updated: [Current Date]` never filled, every Phase 0/1 checkbox unchecked including finished work, no mention of 3D. Superseded by `CANON.md` §8 and the 48 files in `.taskmaster/tasks/` |
| `project_info_export/story_design.md` | **delete** | alternate act names (The Schism / Sunken Cathedral / Womb of Creation) conflict with `CANON.md` §2. **Its narrative substance is preserved** — absorbed into the act table in §2, along with its protagonist framing |
| `project_info_export/prd.md` | **edit, do not delete** | Only its opening framing is wrong ("the entire experience is procedurally generated", roguelike comparables). Its §4.2 describes the correct hybrid model and is canon. Fix the two offending lines in place — deleting the file would remove canon-aligned content |

---

## Tier 3 — DO NOT DELETE

These look like duplicates on a fast read. They are not.

| Path | Why it stays |
|---|---|
| `story_design.md` (root) | source of the canonical act names in `CANON.md` §2 |
| `design.md` (root) | 447 lines of the author's systems design — Blood Echoes, Mutations, classes, weapon/armor/artifact/curse vocabulary, enemy roster. Its combo combat is superseded by `CANON.md` §1; **everything else remains valid source material** |
| `project_info_export/feature_description.md` | **now a canon source.** Describes the hybrid handcrafted+procedural model correctly — the file the failed `d8f0787` correction got right |
| `project_info_export/ui_style_description.md` | **now a canon source.** Sole origin of the HUD layout and typography in `CANON.md` §6 |
| `project_info_export/executive_summary.md` | external-facing framing and market positioning; no conflict with canon |
| `memory-bank/**` | the art bible, tag system and generation model. Source of `CANON.md` §1, §2, §4, §5 |

---

## Not a deletion — a merge decision that needs a human

**Two main menus exist and neither is usable as-is.**

- `dotbg/scenes/main_menu.tscn` — *is* the project's `run/main_scene`, but its
  "Start Game" button only prints `"TODO: Implement game start"`.
- `dotbg/scenes/main/main.tscn` + `main.gd` — more complete, with a working
  `start_new_game()` that resets `GameManager`/`PlayerStats` state — but it is
  **not** the `main_scene`, so it is unreachable in play, and it instances
  `test_level.tscn`, which Tier 1 removes.

The working `start_new_game()` logic has to be carried over and its 2D level
reference replaced with a 3D scene before the redundant menu goes. Flagging
rather than guessing.

---

## Execution note

Deletions are staged on branch `chore/canonization` and recoverable from git
history. They are still deletions — confirm before running.
