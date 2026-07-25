# CANON — Depths of the Bastard God

**This is the single source of truth for this project.** Where any other document
disagrees with this file, this file wins and the other document is wrong.

Established 2026-07-25. Revision 2 — merges Vision 2 (`project_info_export/`)
and Vision 3 (`memory-bank/` + `.taskmaster/docs/prd.txt`) into one spec.

---

## 0. Inherited context

Original author: **Sh4ttr** (`v4mp@void.local`). All 11 commits fall between
2025-06-03 and 2025-06-07 — a five-day burst, dormant ~13.5 months since.

The current maintainer is **not** the original author and works under an explicit
constraint: **the author's game concept is preserved.** Genre, tone, perspective,
systems, story and the three-act structure are not up for redesign. What changes
is the *content budget*, which is a quantity, not an idea.

### The three visions, and why this document exists

The repo contains three drafts of the same game, written in sequence. They are
not competing designs — they are one design mid-migration, and the contradictions
are seams where a rewrite stopped halfway.

| | Structure | Presentation | Combat |
|---|---|---|---|
| **V1** — root docs | run-based, 3 acts × 5 dungeons + Endless Mode | unspecified | fast combos |
| **V2** — `project_info_export/` | free-exploration, anti-"linear Soulsvania" | 2.5D = 3D orthogonal camera | methodical Soulslike |
| **V3** — `memory-bank/` | free-exploration, "NOT A ROGUELIKE" | 2.5D = 2D sprites in 3D world | unspecified |

**This canon merges V2 and V3.** V1 is retained as source material only — its
systems and item design remain valid input, its run-based structure and combo
combat do not.

---

## 1. What the game is

A **2.5D Gothic horror action-adventure**: 2D animated sprite characters moving
through real 3D Gothic environments, under a fixed orthogonal camera at ~45°
(Hades-style). Eight-directional movement. Locked references: **Hades**
(perspective, animation, atmosphere, proven touch ports) and **Hyper Light
Drifter** (8-directional fluid movement).

### Structure: free exploration, NOT a roguelike

Stated verbatim in `memory-bank/corrected_art_prompt.md:10`. The world is
**handcrafted, persistent and interconnected**. A quest system deliberately
routes the player back through earlier areas. Explicitly positioned against
"linear Soulsvania" design.

Any document claiming "the entire experience is procedurally generated" is
superseded — including the executive framing of `project_info_export/prd.md`,
whose own §4.2 already describes the correct hybrid model.

### Combat: methodical Soulslike

From `project_info_export/prd.md`, and canon:

> *"slow, deliberate, and punishing... emphasizes careful timing, strategic
> positioning, and stamina management over fast reflexes... no long, cancelable
> combos."*

Stamina gates attacking, dodging and blocking. This **supersedes** the fast
combo-based combat described in root `design.md`.

Status effects, canonical names across all three visions: **Bleeding,
Corruption, Madness, Poison, Curse.**

---

## 2. Story canon

**Act names come from V3** (corroborated by `memory-bank/progress.md` lines
128/146/163). **Act substance is enriched from V2**, whose narrative is more
specific and whose religious framing makes the religious-horror register land
harder. The two are compatible — V2 renamed the acts but kept their shape.

**Protagonist:** an **acolyte of a forgotten faith**, marked by eldritch
knowledge. (V2's specificity, layered onto V1/V3's framing — this is the one
place where merging required a judgment call. Flagged in §10.)

**Premise:** The Bastard God, born of the forbidden union of mortal and divine,
sleeps beneath an ancient city. Its dreams corrupt reality as it nears waking —
architecture twists, citizens become grotesque reflections of themselves.

| Act | Title | Substance | Boss |
|---|---|---|---|
| I | **The Descending City** | A religious schism tears the city apart as the entity's influence grows; the faithful twist into zealots, reality frays at the edges. The player navigates a collapsing city pursued by fanatical remnants of the old church. Beats: The Great Collapse, The First Revelation, The Mirror Moment, The Church's Fall. | **The Architect** — former city planner, now a reality-bending horror who *uses architecture as a weapon* |
| II | **The Drowning Depths** | The city's heart sinks, revealing an older submerged civilization that once worshipped the entity — and whose containment rituals failed. Flooded catacombs, bone churches, flesh gardens. Beats: The Flood, The Mass Fusion, The Deep Echo, The Revelation of Blood. | **The Amalgam Mother** — a mass of fused citizens; each phase surfaces a different memory |
| III | **The Dream Realm** | Dream-like, fully malleable reality. The Bastard God is revealed as born from the nexus of faith, fear and cosmic indifference. Beats: The Reality Shatter, The Time Collapse, The Truth of Creation, The Final Choice. | **The Bastard God** — multiple forms driven by player actions; the arena shifts through realities |

**Recurring NPCs:** The Curator, The Mirror Witch, The Chronicler, The Wanderer,
**The Other You** (from another timeline). NPCs are unreliable narrators — their
perceptions warped by the ambient madness, giving conflicting accounts.

**Horror registers**, invariant across all three visions: **Cosmic, Gothic,
Religious, Body.**

**Endings**, gated by sanity, artifacts and NPC survival:
1. **Transcendence** — high sanity + specific artifacts; the player becomes a new
   kind of entity; reality stabilizes in a new form.
2. **Corruption** — low sanity + many mutations; the player merges with the
   Bastard God; reality fully corrupts.
3. **Sacrifice** — specific NPCs alive + items; the breach is sealed; return to
   normal, at a cost.

The alternate act names in `project_info_export/story_design.md` (The Schism /
The Sunken Cathedral / The Womb of Creation) are **not** canon as names. Their
*content* is absorbed above.

---

## 3. Core systems

- **Sanity** — the central psychological-horror mechanic. Drops from eldritch
  damage, reading forbidden texts, witnessing cosmic horror. Drives visual
  corruption (§5), audio hallucination, false enemies and UI corruption (§6).
- **Blood Echoes** — primary currency, "crystallized memories of the dead."
- **Black Market** — trades in **Sanity instead of Echoes**.
- **Mutations** — permanent, **hard cap of 3**. Categories: Cosmic (high
  risk/reward), Physical (appearance), Mental (new abilities).
- **Classes** — Cultist (high sanity / low HP, gains sanity on kill, reads
  forbidden texts without cost), Warrior (high HP / low sanity), Scholar (very
  high sanity / very low HP, identifies items on pickup, senses secrets).
  *v1.0 ships one class — see §8.*
- **Curses on items** — buffs with drawbacks, which can be cleansed *or
  embraced*: Blood Price, Mind Fracture, Void Touch, Echo Curse.
- **Companions** — rescuable NPCs who **corrupt at low sanity**: Lost Scholar,
  Fallen Priest, Mad Hunter, Void Touched. *Post-v1.0.*

Item, weapon, armor and enemy design in root `design.md` remains valid source
material — the naming vocabulary (*The Poet's Pen*, *Madness Incarnate*, *The
Black Mirror*, *The Forgotten* who "cannot be killed, only banished") is the
author's and is preserved.

---

## 4. Hybrid generation model

**Handcrafted:** the overarching world, key landmarks, quest locations, the
connections between areas, act structure, scripted narrative beats, boss
encounters, base room layouts.

**Procedural:** dungeon interior layouts, a subset of enemy placements and
variants, loot randomization — always layered onto a handcrafted anchor.

### The tag system

The mechanism that fuses the two. Entities and rooms are composed from a
combinatorial tag vocabulary:

| Category | Tags |
|---|---|
| BASE | `humanoid` `beast` `construct` `spirit` `amalgam` |
| CORRUPTION | `deformed` `burning` `mad` `false` |
| SANITY | `real` `hallucination` `disguised` `lying` |
| QUALITY | `crude` … `masterwork` `cursed` `blessed` |

**Hard rules:**
- Forbidden pairs: `fast`+`slow`, `real`+`hallucination`, `blessed`+`cursed`,
  `fire`+`water`
- Required pairs: `false` requires `hallucination`+`lying`; `disguised` requires
  `real`
- **Maximum 6 tags per entity** — mobile performance ceiling

Flow: pull base template from HandcraftedManager → apply procedural tag
modifications → validate through SafetyChecker (softlock detection, connectivity,
performance budget, narrative coherence).

Budgets: **<2s generation, <1.5GB RAM, 60 FPS.**

---

## 5. Art direction

The fullest artifact in the repo is `memory-bank/corrected_art_prompt.md`. It is
canon. Foundational aesthetic: **authentic Gothic cathedral architecture with
reality-bending horror corruption** — real flying buttresses, ribbed vaults,
pointed arches, referencing *Castlevania: SotN* and real cathedrals.

### Per-act progression

| Act | Palette | Architecture & materials |
|---|---|---|
| I — Gothic city | deep blacks + rich burgundy; candlelit shadow, warm amber | cathedral interiors, ribbed vaulting, arbotantes; clean limestone, aged oak, tarnished bronze; dust motes, stained glass |
| II — Sacred catacombs | + bone whites, dusty browns | bone-lined walls in Gothic proportion, skulls integrated into arches, torchlight on stone and standing water |
| III — Another plane | + reality-breaking impossible colors | **non-Euclidean**: arches to impossible spaces, buttresses supporting nothing, windows onto alien skies, breathing stonework, shadows mismatched to objects |

### Sanity corruption — four discrete visual tiers

This is a build spec, not a mood board.

- **100%** — crisp stonework, warm candlelight, true arches, beautiful stained
  glass. *The Gothic cathedral at its most beautiful and authentic.*
- **75%** — subtle wrongness: stone slightly rough, shadows slightly too long,
  arches slightly off, glass colors muted.
- **50%** — obvious corruption: organic breathing stone, sickly candlelight,
  independently-moving shadows, twisted arches, disturbing stained-glass imagery,
  metal rusting and bleeding.
- **0%** — total breakdown: fully organic diseased writhing stone, impossible
  light sources, non-Euclidean nightmare geometry.

### Composition and pipeline

Four-layer 3D composition: Foreground (columns, interactive objects) · Middle
Ground (floor, altars, navigation) · Background (distant arches, stained glass,
depth) · Vertical (ceilings, buttresses, tower interiors).

Environments modeled in **Blender**. Characters are **2D animated sprites**, not
3D models. Mobile: LOD by distance, ETC2/ASTC compression, texture atlases,
managed poly counts.

**Canonical palette** (`memory-bank/sprite_list.md`): `#1a1a1a` deep black ·
`#4a4a4a` stone gray · `#8b0000` burgundy · `#cd7f32` tarnished bronze ·
`#ffbf00` amber · `#fff8dc` candlelight · `#228b22` corruption green ·
`#663399` corruption purple.

---

## 6. UI and HUD

**Layout comes from V2** (`project_info_export/ui_style_description.md`).
**Material language comes from V3.**

### Layout — landscape

- **Left:** context-aware semi-transparent virtual joystick that appears where
  the thumb first lands.
- **Right:** action cluster — large central Primary Attack, Dodge Roll adjacent,
  multi-purpose Interact, smaller weapon/ability buttons.
- **Top-left:** Health bar + Sanity bar, visually distinct from each other.
- **Top-right:** Blood Echoes count + small pause cog.
- **Bottom-center:** transient pickup / quest notifications.

### Material language

Virtual controls styled as Gothic architectural elements: stone-textured joystick
base, tarnished bronze action buttons, candlelight-glow highlights, semi-
transparent so architecture stays visible. Health and sanity bars styled as
**stained-glass windows**. Inventory presented as a **Gothic illuminated
manuscript**. Map styled as a Gothic architectural drawing.

### Typography

Headings: stylized Gothic/serif that stays readable — Cinzel, Uncial Antiqua.
Body and UI: clean sans — Lato, Open Sans. Icons: simple, high-contrast,
stylized; clarity over intricacy.

### UI corruption

At low sanity the interface itself becomes a horror vector: **health bars that
lie, randomized item descriptions, false map layouts.** These patterns are
partly hand-designed, not purely procedural.

---

## 7. Platform

**Android + PC (Steam).** Landscape on both.

Android stays first-class — the existing 2,550-line touch input layer is the
project's strongest asset. PC is added because Godot exports to it at near-zero
cost and it changes the commercial ceiling by an order of magnitude.

Input: touch (Android), gamepad + KBM (PC), both routed through
`input_manager.gd`.

Any document stating "Android ONLY" or "portrait orientation" is superseded.

**Audience** (V2): core mobile players who want challenging action RPGs and
horror — fans of *Dead Cells*, *Pascal's Wager*, mobile Souls-likes. Secondary:
Gothic-horror aesthetes (*Castlevania*, *Bloodborne*).

---

## 8. Scope

**The 50-70 hour target is dead.** So is the "3-4 year, 10-phase" plan.

No shipped Metroidvania reaches that length. *Symphony of the Night* ~12h.
*Blasphemous* ~13h. *Ender Lilies* ~12h. *Hollow Knight* ~27h main — three
people, three years, Kickstarter. The stated inspiration runs twelve hours.

### v1.0 ships Act I only — The Descending City. Target 3-5 hours.

Acts II and III remain canon and remain the roadmap; they ship as post-launch
content. The author's three-act structure is preserved intact — only delivery is
staged.

**v1.0 budget:** one act · one class · 8-12 enemy types · 3 bosses ending with
The Architect · one ending path · Sanity active · Blood Echoes active.

**Post-v1.0:** Mutations, companions, Black Market, remaining classes, remaining
endings, Acts II-III.

---

## 9. Known integrity defects

Verified by code audit 2026-07-25. State of the repo as inherited.

1. **~2,026 lines of procedural generation never execute.** `scripts/hybrid/*.gd`
   declares no `class_name`; the five class names are declared *only* in
   `scripts/systems/*.gd`, which are 2-4 function stubs returning hardcoded
   `{"name": "Placeholder ..."}`. `HybridGenerator` instantiates by class name,
   so Godot resolves to the stubs. Nothing loads `scripts/hybrid/` by path.
2. **All cross-autoload signal wiring is commented out** behind
   `# TODO: Fix signal connections after autoload initialization`.
3. **No playable loop.** `main_menu.tscn` is `run/main_scene`; its Start Game
   button prints `"TODO: Implement game start"` and loads nothing.
4. **A second, more complete main menu** (`scenes/main/main.tscn`) has a working
   `start_new_game()` — and is unreachable, not being the `main_scene`.
5. `scenes/test_input.tscn` references `res://scripts/ui/touch_button.gd`, absent.
6. `sanity_manager.gd:151` emits `"sanity_corruption_reset"`, undeclared in
   `event_bus.gd`.
7. No test framework, no CI, no art assets, no audio.

**Do not resurrect the orphaned procgen until a running game exists to put it
in.** It has executed zero times — a hypothesis, not an asset. Re-enabling is
cheap, which is a reason to *test* it early, not to bet on it.

---

## 10. Open decisions

- **Protagonist framing.** §2 adopts V2's "acolyte of a forgotten faith" over
  V1/V3's vaguer "marked by eldritch knowledge," on the grounds that it is more
  specific and strengthens the religious-horror register. This was a merge
  judgment call, not something the source documents settle. Overrule here if
  wrong.
- **First external playtest date.** Not set. Percent-complete is the wrong
  metric; this is the right one.

---

## 11. Superseded documents

| Document | Conflict |
|---|---|
| `project_info_export/prd.md` | **header only** — "entire experience is procedurally generated" and roguelike framing. Its §4.2 hybrid detail is canon |
| `project_info_export/story_design.md` | alternate act *names*; content absorbed into §2 |
| `roadmap.md` | "Pre-Development", unfilled `[Current Date]`, all Phase 0/1 unchecked, no 3D |
| `design.md` (root) | pre-3D concept; **combo combat superseded by §1**. Systems and item vocabulary remain valid source material |
| `.taskmaster/tasks/task_001.txt` | portrait orientation, marked done |
| `README.md` | declares `.taskmaster/tasks/tasks.json` canonical; that file does not exist |

**Now canon sources, not superseded:** `project_info_export/feature_description.md`
(hybrid model), `project_info_export/ui_style_description.md` (§6 layout and
typography), all of `memory-bank/`.

---

## 12. The only metric that counts

~8,700 lines of code. **Zero seconds of gameplay.**

Until v1.0, progress is measured in **seconds of verified, running, replayable
gameplay** — not lines, not tasks closed, not percent complete.

First milestone: `main_scene` boots → a sprite character walks through a 3D
Gothic space → a headless test asserts it.

---

## 13. Amendment rule

This document may be **edited**. New documents restating scope, story, platform
or art direction may **not** be created. If this canon is wrong, fix it here — do
not write a second opinion elsewhere. That failure mode produced §9 and §11.
