export const meta = {
  name: 'phase2-core-loop',
  description: 'Phase 2: build the core loop until its gate exits 0 — stamina combat, one enemy, death and restart',
  whenToUse: 'ROADMAP.md Phase 2. Run first; every later phase assumes a playable loop exists.',
  phases: [
    { title: 'Spec', detail: 'Combat design derived from canon and the signed tuning contract', model: 'fable' },
    { title: 'Build', detail: 'Sequential TDD units — heavy tool runs must never overlap' },
    { title: 'Gate', detail: 'Drive the real gate until it exits 0, or stop and say why' },
    { title: 'Verify', detail: 'Independent adversarial lenses, then repair what blocks' },
    { title: 'Ship', detail: 'Export a build a human can play, and write the run journal' },
  ],
}

// Phase 2 is the first time this is a game rather than a tech demo. The gate is
// a headless test driving scripted input through enter -> fight -> win and
// enter -> die -> restart. Everything here exists to make that command exit 0.
//
// Goal-shaped on purpose: agents get the end state and the check, not a
// procedure. The one thing that is prescribed is the standard of done, because
// that is the thing this repo has historically got wrong.

const REPO = 'C:\\Users\\jovy2\\Projects\\DotBG'
const HARNESS = 'powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1'

const PREAMBLE = `
Repository: ${REPO}. The Godot 4.7 project is the dotbg/ subdirectory; res:// is
that directory. Branch: work on the current one, never main.

READ FIRST, in order: CANON.md, AGENTS.md, ROADMAP.md. They are the only binding
documents and are written to be self-sufficient. Then read
dotbg/scripts/config/tuning.gd — the signed numeric contract. You may not change
its values; they were approved by a human on 2026-07-25.

THE HARNESS — run it after every change, and before claiming anything:

    ${HARNESS}

Exits 0 on pass. Godot is NOT on PATH; always go through the runner.

HARD RULES from AGENTS.md §7:
- Never two heavy tool jobs at once. ~1GB RAM free. Never open the Godot editor.
- Never mark an art asset approved, and never judge that combat feels right.
  Both are human calls and an agent grading its own output is the defect this
  project is built around.
- Never edit CANON.md, AGENTS.md, ASSETS.md or ROADMAP.md — report instead.
- Never push, never touch main, never delete more than ~200 lines at once.
- Check for a file named STOP at the repo root between units. If it exists,
  finish cleanly, write what you did, and exit.
- Commit your unit when it is green. Conventional Commits, body explains WHY.
  End with: Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>

THE STANDARD OF DONE. This repo's founding defect is code written and never run.
A unit is done when an assertion proves the behaviour and the suite is green.
Tests that can pass vacuously are not tests — if you assert over a collection,
first assert the collection is non-empty. That exact mistake has already shipped
twice here: a check that a file was larger than zero bytes passed on an empty
glTF, and a source scan passed while a type error left it scanning nothing.

TELLING THE TRUTH IS THE JOB. A truthful "blocked" is worth more than a false
"green". The agent after you reads your notes and will waste hours on a lie.
`

const UNIT = {
  type: 'object',
  required: ['unit', 'status', 'suite_output', 'notes'],
  properties: {
    unit: { type: 'string' },
    status: { type: 'string', enum: ['green', 'partial', 'blocked'] },
    suite_output: { type: 'string', description: 'Verbatim final lines of the harness run' },
    files_changed: { type: 'array', items: { type: 'string' } },
    committed: { type: 'boolean' },
    notes: { type: 'string', description: 'What is unfinished, and anything noticed but not touched' },
  },
}

const GATE = {
  type: 'object',
  required: ['gate_passes', 'evidence', 'what_is_missing'],
  properties: {
    gate_passes: { type: 'boolean' },
    evidence: { type: 'string', description: 'Verbatim command output, not a summary' },
    what_is_missing: { type: 'string' },
    can_an_agent_fix_it: { type: 'boolean' },
  },
}

const VERDICT = {
  type: 'object',
  required: ['dimension', 'blocking', 'findings'],
  properties: {
    dimension: { type: 'string' },
    blocking: { type: 'boolean', description: 'Would this make a human playtest misleading or impossible?' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['summary', 'file', 'severity'],
        properties: {
          summary: { type: 'string' },
          file: { type: 'string' },
          severity: { type: 'string', enum: ['critical', 'major', 'minor'] },
          evidence: { type: 'string' },
        },
      },
    },
  },
}

// ----------------------------------------------------------------- spec --

phase('Spec')

const spec = await agent(`${PREAMBLE}

GOAL: a brief precise enough that three implementers never have to guess.

Write no code and change no files. Every number comes from Tuning; if something
needs a value Tuning lacks, say so and propose one with reasoning rather than
inventing it silently.

Specify these three units, in dependency order:

1. PLAYER COMBAT STATE MACHINE — dotbg/scripts/characters/player/player_3d.gd.
   States and transitions. The attack commitment window is
   Tuning.light_commitment() and nothing cancels it. The dodge is invincible for
   Tuning.DODGE_IFRAMES and then VULNERABLE for the remainder of
   Tuning.DODGE_TOTAL — that tail is the entire Soulslike model per CANON.md §1;
   without it this is Hades. Both gated by PlayerStats.spend_stamina(), which
   exists and already allows overdraw.

2. ONE ENEMY — new scene and script. Idle, aggro on proximity, approach, attack
   with its own commitment, take damage, die. Movement is direct on the XZ
   plane; no NavigationServer, no pathfinding. Must be drivable headlessly.

3. DAMAGE, DEATH, RESTART, ECHOES — player takes damage, loses
   Tuning.SANITY_ELDRITCH_DAMAGE sanity per hit, dies at zero health, run
   restarts through GameManager. A dead enemy drops Blood Echoes collected by
   proximity.

For each: exact files, public API, signals emitted and whether they need
declaring in EventBus (the suite forbids the unchecked emit_signal("...") string
form), and the assertions its test must make.

Say how a headless SceneTree test drives time and scripted input for
time-based combat. Read the existing tests in dotbg/tests/ for the patterns that
already work here.

Placeholder audio exists at res://assets/audio/placeholder/ — player_hurt,
player_death, attack_swing, attack_impact, dodge_roll, echoes_pickup. Say where
each triggers, so tomorrow's playtest has audible feedback.`, {
  label: 'spec:combat', phase: 'Spec', model: 'fable', effort: 'high',
})

// ---------------------------------------------------------------- build --

phase('Build')

const UNITS = [
  { key: 'combat', title: 'Player combat state machine', test: 'dotbg/tests/combat_test.gd',
    asserts: 'an attack cannot be cancelled inside its commitment window; the dodge is invincible for exactly Tuning.DODGE_IFRAMES and vulnerable afterwards; both spend the contract stamina; neither starts on an empty pool' },
  { key: 'enemy', title: 'One enemy', test: 'dotbg/tests/enemy_test.gd',
    asserts: 'it starts idle, aggros within range, closes distance over simulated time, deals damage on attack, loses health when hit, and dies at zero emitting its death signal' },
  { key: 'loop', title: 'Damage, death, restart, Blood Echoes', test: 'dotbg/tests/core_loop_test.gd',
    asserts: 'TWO scripted runs — enter/fight/win and enter/die/restart — checking health, stamina, sanity and Blood Echoes at every step. This test is the Phase 2 gate; make its failure messages say what actually broke' },
]

const built = []
for (const unit of UNITS) {
  const result = await agent(`${PREAMBLE}

APPROVED SPEC — follow it:
--- BEGIN ---
${spec}
--- END ---

YOUR UNIT: ${unit.title}

Write ${unit.test}. It must assert: ${unit.asserts}.

Work test-first. Drive time explicitly rather than waiting on real frames — a
timing test racing the engine measures the engine. Run the harness until
everything is green, including the assertions that already passed before you
started; breaking those is a failure, not a tradeoff. Then commit.`, {
    label: `build:${unit.key}`, phase: 'Build', model: 'sonnet', effort: 'high', schema: UNIT,
  })
  built.push(result)
  log(`${unit.title}: ${result ? result.status : 'agent died'}`)
}

// ----------------------------------------------------------------- gate --

phase('Gate')

// Loop on the real gate rather than trusting the builders' self-reports. Three
// attempts, then stop and say what is missing — an agent that keeps trying is
// how an unattended run burns a night producing nothing.
let gate = null
for (let attempt = 1; attempt <= 3; attempt++) {
  gate = await agent(`${PREAMBLE}

GOAL: make the Phase 2 gate exit 0, or establish honestly that it cannot.

The gate is ROADMAP.md Phase 2: a headless test drives scripted input through
enter -> fight -> win, and separately enter -> die -> restart, asserting health,
stamina, sanity and Blood Echoes at each step.

Run the harness. Read what it actually printed, not the summary line. If the
gate passes, report the verbatim output as evidence and stop. If it does not,
fix the smallest thing standing in the way and run it again.

This is attempt ${attempt} of 3. Do not rewrite anyone's design. If what remains
is beyond a focused fix, set gate_passes false and describe precisely what is
missing and whether an agent could finish it.`, {
    label: `gate:attempt-${attempt}`, phase: 'Gate', model: 'sonnet', effort: 'high', schema: GATE,
  })
  if (gate && gate.gate_passes) { log(`Gate green on attempt ${attempt}`); break }
  log(`Gate attempt ${attempt}: ${gate ? gate.what_is_missing : 'agent died'}`)
  if (gate && gate.can_an_agent_fix_it === false) { log('Gate needs a human; stopping the loop'); break }
}

// --------------------------------------------------------------- verify --

phase('Verify')

const LENSES = [
  { key: 'vacuous', brief: `Hunt for assertions that cannot fail. For every test added, ask whether it would still pass if the feature were deleted or stubbed. Prove it: change a value, run the harness, confirm the right test goes red, then git checkout to revert. Report any test that stayed green.` },
  { key: 'contract', brief: `Verify every timing, speed and cost reads from Tuning — no hardcoded numbers anywhere in the new code. Check specifically that the dodge has a real vulnerable tail after its invincible window and that the attack commitment genuinely cannot be cancelled. Those two ARE the combat model, and an implementation can look right while silently having neither.` },
  { key: 'integrity', brief: `Check the defect families in CANON.md §9: a class_name colliding with a Godot 4.7 native class or an existing one, a signal emitted but never declared, a second source of truth for something Tuning or PlayerStats already owns, unreachable code, dead files. Run the harness and read the real output.` },
  { key: 'playable', brief: `Ignore the tests. Ask whether a human opening this build tomorrow can actually do anything: does the start button reach gameplay, is an enemy present, can the player hit it, does anything happen when they die, is there audible feedback? Report what a first-time player would hit as a wall, in their words rather than in code terms.` },
]

const verdicts = (await parallel(LENSES.map(lens => () => agent(`${PREAMBLE}

Review the work just committed. Start with:
    git log --oneline -10
    git diff HEAD~4 --stat

LENS: ${lens.key}
${lens.brief}

Be adversarial and specific. Every finding carries a file, a line, and what you
actually ran or read. No style preferences. Fix nothing — report only.
Set blocking true only for something that makes tomorrow's playtest misleading
or impossible.`, {
  label: `verify:${lens.key}`, phase: 'Verify', model: 'opus', effort: 'high', schema: VERDICT,
})))).filter(Boolean)

const blocking = verdicts.filter(v => v.blocking)
log(`Verification: ${verdicts.length} lenses, ${blocking.length} blocking`)

if (blocking.length > 0) {
  const repair = await agent(`${PREAMBLE}

Adversarial review found blocking problems. Fix those, and only those.

--- FINDINGS ---
${JSON.stringify(blocking, null, 2)}
--- END ---

For each: fix it and prove it with a harness run, or explain with evidence why
the reviewer was wrong. Reviewers are sometimes wrong — do not implement a fix
you believe is incorrect. Commit when green.`, {
    label: 'verify:repair', phase: 'Verify', model: 'sonnet', effort: 'high', schema: UNIT,
  })
  log(`Repair: ${repair ? repair.status : 'agent died'}`)
}

// ----------------------------------------------------------------- ship --

phase('Ship')

const shipped = await agent(`${PREAMBLE}

GOAL: something a human can play in the morning, and an honest record of what
happened while nobody was watching.

1. Run the full harness and capture verbatim output.

2. Export a Windows build. Templates are installed and dotbg/export_presets.cfg
   exists. Resolve the Godot binary the way tools/run_tests.ps1 does:

     <godot> --headless --path dotbg --export-release "Windows Desktop" "..\\build\\windows\\dotbg.exe"

   Then RUN the exported binary with --headless --quit-after 60 and confirm it
   boots with exit 0. A file existing is not a game booting — that confusion has
   cost this project twice.

3. Write runs/<UTC timestamp>.md per AGENTS.md §7.4: what was attempted, verbatim
   gate output, what was refused and why, what was left half-done, what the next
   session should pick up. It is a log, never authoritative.

4. End that journal with a PLAYTEST NOTE in plain language: how to launch it,
   what to try, what is expected to work, what is knowingly missing or ugly. Be
   honest about rough edges — he will find them anyway, and a note that oversells
   is worse than none.

5. Commit the journal. Do not push, do not tag, do not touch main.`, {
  label: 'ship:build', phase: 'Ship', model: 'sonnet', effort: 'high',
  schema: {
    type: 'object',
    required: ['suite_output', 'build_ok', 'journal_path', 'playtest_note'],
    properties: {
      suite_output: { type: 'string' },
      build_ok: { type: 'boolean' },
      build_bytes: { type: 'number' },
      journal_path: { type: 'string' },
      playtest_note: { type: 'string' },
      left_undone: { type: 'string' },
    },
  },
})

return {
  phase: 'Phase 2 — the core loop',
  gate_passes: gate ? gate.gate_passes : false,
  gate_evidence: gate ? gate.evidence : 'never reached',
  units: built.filter(Boolean).map(u => ({ unit: u.unit, status: u.status, notes: u.notes })),
  blocking_findings: blocking.length,
  build: shipped ? { ok: shipped.build_ok, bytes: shipped.build_bytes } : 'ship agent died',
  journal: shipped ? shipped.journal_path : null,
  playtest_note: shipped ? shipped.playtest_note : null,
  next: gate && gate.gate_passes
    ? 'Phase 2 gate is green. A human playtest for feel is the remaining gate item; then run phase3-art-pipeline.'
    : 'Phase 2 gate is NOT green. Do not start Phase 3 — read the journal and finish this first.',
}
