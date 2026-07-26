# ROADMAP — Depths of the Bastard God

Execution plan. **Scope, story, art and platform live in `CANON.md`** — this file
only sequences the work and defines how each phase proves it is done.

Written 2026-07-25. Supersedes the deleted `roadmap.md`, which was a checklist of
unchecked boxes with no gates and no dates.

---

## The rule that makes this different from the last roadmap

**Every phase ends with a gate that a machine can check.** Not "looks done", not
a screenshot judged by the model that wrote the code — a command that exits 0 or
1. The previous roadmap had 60+ checkboxes and the project shipped zero seconds
of gameplay in 13 months. The gates are the whole point.

Current harness:

```bash
godot --headless --path dotbg --script res://tests/boot_test.gd
```

Every phase below extends it.

---

## Phase 0 — Canonization and first boot ✅ COMPLETE (2026-07-25)

One canon replacing three contradictory visions, with a document registry so
authority is explicit. 2D branch removed. `.gitignore` repaired, 5.7MB of editor
cache untracked. `GameManager` given real run state. Menu consolidated. Project
boots to a 3D scene. `ASSETS.md` established the asset lifecycle.

**Gate — met:** 19 checks, 0 failures, exit 0. Seven autoloads load,
`start_new_game()` resets run state and sanity, the 3D scene loads, the player is
simulated and standing, the camera is orthogonal at a measured 45.00°.

```bash
godot --headless --path dotbg --script res://tests/boot_test.gd
```

### Art references — Stage 1 approved, Stage 2 queued

Five approved references live in `art/approved/` with provenance sidecars: the
cathedral hall at all four sanity-corruption tiers, plus the canonical Acolyte
turnaround. These fix the visual target for Phase 3.

Twenty-five Stage 2 requests are queued in
`C:\Users\jovy2\Documents\Codex\claude-imagegen-inbox\pending` — Act I
environments, enemies and combat moments, the three Architect phases, and UI
screens including a dedicated canonical HUD reference. All twenty-five carry the
byte-identical approved style header (`bc2329e4625f`).

**The queue has no watcher.** Nothing processes it automatically. To run a
request, in the FOREGROUND only:

```bash
timeout 540 codex exec -C "C:\Users\jovy2\Projects\DotBG" -s workspace-write "Genera UNA imagen y NO la copies. Lee <queue>\<name>.md, pasa todo el texto tras 'prompt:' tal cual a image_gen.imagegen, y reporta que terminaste." < /dev/null
```

Then count PNGs in `~/.codex/generated_images` before and after, copy the newest
by mtime into `art/candidates/` yourself, and hash-verify. Codex has reported
success while returning a stale copy — never trust its self-report or let it move
files. Approved output moves to `art/approved/` with a sidecar; rejects keep the
sidecar and lose the bytes, per `ASSETS.md` §4.

---

## Phase 1 — Foundation integrity
*Estimate: 1-2 weeks · mostly agent-delegable*

Make what already exists correct and verified before building on it.

| Work | Detail |
|---|---|
| Movement tuning | `speed = 200.0` is a 2D pixels/second value on a 2m capsule — 720 km/h. Retune for methodical Soulslike (`CANON.md` §1): walk, run, dodge, stamina cost |
| Purge 2D leftovers | `PlayerStats` still carries `jump_force`, `max_jumps`, `air_control`. No jump exists under a fixed orthogonal camera |
| Reconnect signals | All cross-autoload wiring in `hybrid_generator.gd` is commented out behind a TODO. Connect it or delete it |
| Fix `EventBus` mismatch | `sanity_manager.gd:151` emits `sanity_corruption_reset`, undeclared in `event_bus.gd` |
| **Procgen verdict** | Run the orphaned `scripts/hybrid/` (~2,026 lines) against real input for the first time. It is cheap to test and has never executed. **Keep it or delete it — do not leave it in limbo** |
| CI | GitHub Actions running the headless suite on every push |

**Gate:** test suite green in CI. Procgen either wired and asserted, or gone from
the repo with the decision recorded in `CANON.md` §9.

---

## Phase 2 — The core loop
*Estimate: 3-4 weeks · agent-delegable with tight specs*

The first time this is a game rather than a tech demo.

- Stamina-gated combat: attack, dodge-roll with i-frames, parry, hit reaction
- One enemy: navigation, aggro, attack, damage, death
- Damage → death → restart loop
- Sanity that actually ticks and drives one visible effect
- Blood Echoes dropping and being collected

**Gate:** a headless test drives scripted input through *enter room → fight →
win*, and separately *→ die → restart*, asserting health, stamina, sanity and
Blood Echoes at each step. Plus one human playtest confirming it feels
deliberate rather than floaty — the one thing a test cannot assert.

---

## Phase 3 — Art pipeline
*Estimate: 4-8 weeks · the real unknown · needs human art direction*

**This is the bottleneck and it must be de-risked before content, not after.**
Everything before this runs on primitives; everything after depends on throughput
proven here.

- Player: rigged `.glb`, 8-15k tris, 7 animation clips (`memory-bank/sprite_list.md`)
- One modular Gothic kit: floor, wall, pointed arch, column, ribbed vault —
  enough to assemble rooms combinatorially
- `corruption.gdshader`: the four sanity tiers from `CANON.md` §5 as a single
  0.0-1.0 parameter over geometry
- UI art: 5 sprites (joystick base and stick, three action buttons)
- Pipeline decision: Meshy / Tripo3D / Blender MCP, and how assets get from
  generation into the repo repeatably

**Gate:** the primitive test box replaced by real Gothic geometry with the real
character in it, holding 60 FPS on a mid-range Android device, with the
corruption shader visibly sweeping 0→1. Measured, not eyeballed.

**Risk:** if throughput here is bad, the Act I content budget shrinks. Better to
learn that at week 8 than at month 8.

---

## Phase 4 — Act I: The Descending City
*Estimate: 4-6 months · the bulk of the work*

The actual game. `CANON.md` §8: 3-5 hours, one act, one class.

- **Level design:** interconnected persistent map, quest system that routes the
  player back through earlier areas (`CANON.md` §1 — free exploration, not linear)
- **Enemies:** 8-12 types from the author's roster — Corrupted Citizens, Plague
  Doctors, Twisted Guards, Street Haunters, Memory Echoes
- **Bosses:** 3, ending with **The Architect**, who uses architecture as a weapon
- **Items:** weapons, armor, artifacts, curses — using the author's vocabulary in
  `design.md`
- **Economy:** Blood Echoes, shops, the Black Market that charges Sanity
- **Sanity at full depth:** the four corruption tiers driving environment, audio
  and the lying-UI patterns
- **Save/load:** the system exists and writes real JSON; wire it to real state
- **Audio:** ElevenLabs MCP for VO and SFX; ambience and music

**Gate:** a fresh install plays start to finish in 3-5 hours without a blocker.
Automated smoke test walks the critical path. Three external playtesters finish
it.

---

## Phase 5 — Ship v1.0
*Estimate: 1-2 months*

- Mobile performance pass: 60 FPS, <1.5GB RAM, <2s generation (`CANON.md` §4)
- PC input: gamepad and keyboard/mouse through `input_manager.gd`
- Export pipeline: Android AAB + Steam build, both from CI
- Store pages, capsule art, trailer
- Closed beta

**Gate:** shipped, on both stores, with a build reproducible from a clean clone.

---

## Post-launch — Acts II and III
*Estimate: 4-6 months each*

Canon, not cut. Staged delivery, not reduced scope.

- **Act II — The Drowning Depths:** submerged civilization, failed containment
  rituals, **The Amalgam Mother**
- **Act III — The Dream Realm:** non-Euclidean geometry, **The Bastard God**
- Then: Mutations, Companions, the remaining two classes, the three endings
  (Transcendence / Corruption / Sacrifice)

---

## Honest timeline

| Milestone | Cumulative |
|---|---|
| Phase 1-2 complete (it's a game) | ~6 weeks |
| Phase 3 complete (it looks like the game) | ~4 months |
| **v1.0 shipped** | **~9-12 months** |
| All three acts | ~2 years |

This assumes one person with agent assistance working steadily. It is not the
"3-4 years for 50-70 hours" the original plan claimed, because that plan was
never achievable — but neither is it fast. Content is content.

---

## Cross-cutting

**Agent workflow.** Orchestrate inline, delegate execution to cheaper models with
explicit specs. Agents lose coherence around 40 minutes and ~30k lines — work in
small verifiable units. Never accept a completion claim without a run
(`AGENTS.md` §2).

**Where agents are strong:** systems code, generation algorithms, tooling,
tests, refactors. **Where they are not:** art direction, encounter design, game
feel, stylistic consistency. Budget human attention accordingly.

**Cost.** Frontier-model budgets for this class of project run in the low
hundreds per month. One data point from the field: a developer shipped five
games, 50k+ lines, on $200/month, and earned $4.99. Build because the finished
thing matters, not because the economics are proven.

---

## The metric

`CANON.md` §12: **seconds of verified, running, replayable gameplay.** Not lines,
not tasks closed, not percent complete.

Today that number is above zero for the first time. Everything in this file is in
service of growing it.
