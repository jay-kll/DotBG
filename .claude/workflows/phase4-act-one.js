export const meta = {
  name: 'phase4-act-one',
  description: 'Phase 4: build Act I content one verified slice at a time, repeatably, until the budget or the gates run out',
  whenToUse: 'ROADMAP.md Phase 4, after Phase 2 is green and Phase 3 has produced geometry. Designed to be run again and again — each run picks up where the last stopped.',
  phases: [
    { title: 'Survey', detail: 'Read the repo and decide what the next slices actually are' },
    { title: 'Slices', detail: 'Build and verify one slice at a time, each ending in a gate' },
    { title: 'Critic', detail: 'What is missing that nobody thought to look for' },
    { title: 'Report', detail: 'Build, journal, and an honest statement of how far this got' },
  ],
}

// Phase 4 is the bulk of the game and will not finish in one run. It is written
// to be run repeatedly instead: each invocation surveys what already exists,
// picks the next slices, builds them behind real gates, and records where it
// stopped so the next run resumes rather than repeats. That is the resumability
// pattern every mature pipeline converged on — stable identity plus an
// idempotent "is this already done" check.
//
// Pass args to steer it: a string naming what to work on. With no args it reads
// the roadmap and decides for itself.
//
//   Workflow({name: 'phase4-act-one'})
//   Workflow({name: 'phase4-act-one', args: 'enemy roster — the first four types'})

const REPO = 'C:\\Users\\jovy2\\Projects\\DotBG'
const STEER = typeof args === 'string' && args.trim() ? args.trim() : null

const PREAMBLE = `
Repository: ${REPO}. Godot 4.7 project is dotbg/; res:// is that directory.

READ FIRST: CANON.md, AGENTS.md, ROADMAP.md. CANON.md §2 is the story, §3 the
systems, §8 the v1.0 scope — one act, one class (the Cultist), 8-12 enemy types,
3 bosses ending with The Architect. design.md is SOURCE MATERIAL with no
authority, but the author's naming vocabulary in it is his and is preserved:
The Poet's Pen, Madness Incarnate, The Black Mirror, The Forgotten who cannot be
killed only banished. Use that voice.

HARNESS — after every change, before every claim:
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1

Numbers come from dotbg/scripts/config/tuning.gd. Placeholder audio is in
res://assets/audio/placeholder/, CC0 ambience in res://assets/audio/ambience/.

HARD RULES from AGENTS.md §7:
- Never two heavy jobs at once. Never open the Godot editor. ~1GB RAM free.
- Never decide an encounter is good, that combat feels right, or that art is
  approved. Those are human calls; build the thing and say what you measured.
- Never edit CANON.md, AGENTS.md, ASSETS.md, ROADMAP.md — report instead.
- Never push, never touch main. Check for a STOP file between slices.
- Commit each slice when green. Conventional Commits, WHY in the body, ending:
  Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>

STANDARD OF DONE: an assertion proves the behaviour and the suite is green.
Content is not exempt. An enemy that exists in a file and has never been spawned
in a test is the same defect as 2,021 lines of procgen that never executed.
`

const SLICE = {
  type: 'object',
  required: ['slice', 'status', 'suite_output', 'notes'],
  properties: {
    slice: { type: 'string' },
    status: { type: 'string', enum: ['green', 'partial', 'blocked'] },
    suite_output: { type: 'string' },
    assertions_added: { type: 'number' },
    committed: { type: 'boolean' },
    notes: { type: 'string', description: 'What is unfinished, and what a human needs to judge' },
  },
}

// --------------------------------------------------------------- survey --

phase('Survey')

const survey = await agent(`${PREAMBLE}

GOAL: decide what to build next, from evidence rather than from the roadmap's
wish list.

${STEER ? `The maintainer steered this run toward: "${STEER}". Take that as the
priority, but still survey first — if it is already done or blocked, say so
plainly instead of redoing it.` : 'No steer was given; choose for yourself.'}

Survey what actually exists: read the test suite, the scenes, the scripts, and
the last few entries under runs/ if any. Then produce an ORDERED list of the
next 3 to 5 slices, each one:

- small enough that a single agent finishes it inside an hour
- independently verifiable, with the exact assertions its test will make
- ordered so nothing depends on something later in the list
- honest about which parts need a human — encounter quality, art approval,
  narrative pacing — versus which are mechanical

Candidate territory from ROADMAP.md Phase 4: enemy roster from the author's
types (Corrupted Citizens, Plague Doctors, Twisted Guards, Street Haunters,
Memory Echoes), the three bosses ending with The Architect who uses architecture
as a weapon, items and curses, the Blood Echoes economy and the Black Market
that charges Sanity, sanity at full depth including the lying-UI patterns in
CANON.md §6, save/load wired to real state, and audio integration.

Prefer the slice that most increases seconds of verified running gameplay — the
only metric in CANON.md §12. Do not pick the one that is most fun to write.

Return the list with, for each: name, what it adds, its exact test assertions,
and its dependencies.`, {
  label: 'survey:next-slices', phase: 'Survey', model: 'opus', effort: 'high',
  schema: {
    type: 'object',
    required: ['slices'],
    properties: {
      slices: {
        type: 'array',
        items: {
          type: 'object',
          required: ['name', 'adds', 'assertions', 'needs_human'],
          properties: {
            name: { type: 'string' },
            adds: { type: 'string' },
            assertions: { type: 'string' },
            depends_on: { type: 'string' },
            needs_human: { type: 'string' },
          },
        },
      },
      already_done: { type: 'string' },
    },
  },
})

const slices = (survey && survey.slices) ? survey.slices : []
log(`Survey chose ${slices.length} slices: ${slices.map(s => s.name).join(', ')}`)

// --------------------------------------------------------------- slices --

phase('Slices')

// Sequential, and gated. Content slices touch overlapping scenes and autoloads,
// and two agents editing GameManager at once produces a merge nobody asked for.
// Three consecutive failures stops the run — an agent that keeps trying is how
// an unattended night burns itself producing nothing.
const done = []
let consecutiveFailures = 0

for (const slice of slices) {
  if (consecutiveFailures >= 3) {
    log('Three consecutive failures — stopping, per AGENTS.md §7.3')
    break
  }

  const result = await agent(`${PREAMBLE}

YOUR SLICE: ${slice.name}

What it adds: ${slice.adds}
Assertions its test must make: ${slice.assertions}
${slice.depends_on ? `Depends on: ${slice.depends_on}` : ''}
${slice.needs_human ? `Needs a human for: ${slice.needs_human} — build around that, do not decide it yourself.` : ''}

Work test-first. Use the author's vocabulary and the canon's register; this is
religious cosmic body horror, not generic fantasy, and a placeholder name that
reads as generic tends to survive to ship.

Run the harness until everything is green, including every assertion that passed
before you started. Then commit.

If you cannot finish, report "partial" or "blocked" with exactly where you
stopped. The next agent reads your notes and a false green costs it hours.`, {
    label: `slice:${slice.name}`.slice(0, 60), phase: 'Slices', model: 'sonnet', effort: 'high', schema: SLICE,
  })

  done.push(result)
  const ok = result && result.status === 'green'
  consecutiveFailures = ok ? 0 : consecutiveFailures + 1
  log(`${slice.name}: ${result ? result.status : 'agent died'}`)

  // Verify each slice as it lands rather than batching review to the end. A
  // wrong slice that later slices build on is far more expensive than one
  // caught immediately.
  if (ok) {
    const check = await agent(`${PREAMBLE}

Adversarially verify the slice just committed: "${slice.name}".

Read the diff. Then attack it: would its tests still pass if the feature were
stubbed out? Prove your answer — break something, run the harness, confirm the
right assertion goes red, revert with git checkout. Check that no number was
hardcoded that Tuning owns, that no signal is emitted undeclared, and that
nothing became a second source of truth.

Report only. Fix nothing. Blocking means later slices would build on something
wrong.`, {
      label: `check:${slice.name}`.slice(0, 60), phase: 'Slices', model: 'opus', effort: 'high',
      schema: {
        type: 'object',
        required: ['blocking', 'findings'],
        properties: {
          blocking: { type: 'boolean' },
          findings: { type: 'array', items: { type: 'string' } },
        },
      },
    })

    if (check && check.blocking) {
      log(`${slice.name}: blocking findings, repairing before continuing`)
      await agent(`${PREAMBLE}

Repair these blocking findings in "${slice.name}", and only these. Prove each
fix with a harness run, or explain with evidence why the reviewer was wrong.
Commit when green.

${JSON.stringify(check.findings, null, 2)}`, {
        label: `repair:${slice.name}`.slice(0, 60), phase: 'Slices', model: 'sonnet', effort: 'high', schema: SLICE,
      })
    }
  }
}

// --------------------------------------------------------------- critic --

phase('Critic')

const critic = await agent(`${PREAMBLE}

GOAL: find what this run missed that nobody thought to look for.

Read what was built tonight (git log, the diff, the test suite) and ask the
questions the builders had no reason to ask:

- What in CANON.md is now contradicted by the code? Canon wins; report the
  contradiction, do not resolve it.
- What was built but is unreachable — no scene references it, no code spawns it,
  nothing can ever hit that path?
- Which assertion is the weakest, in the sense that it would survive the feature
  being deleted?
- What did every agent silently assume?
- Where has "seconds of verified running gameplay" — CANON.md §12, the only
  metric — actually increased tonight, and where does it merely look like it has?

Report only. Be concrete: file, line, evidence.`, {
  label: 'critic:completeness', phase: 'Critic', model: 'opus', effort: 'xhigh',
  schema: {
    type: 'object',
    required: ['gaps', 'weakest_assertion', 'gameplay_seconds_gained'],
    properties: {
      gaps: { type: 'array', items: { type: 'string' } },
      canon_contradictions: { type: 'array', items: { type: 'string' } },
      unreachable: { type: 'array', items: { type: 'string' } },
      weakest_assertion: { type: 'string' },
      gameplay_seconds_gained: { type: 'string' },
    },
  },
})

// --------------------------------------------------------------- report --

phase('Report')

const report = await agent(`${PREAMBLE}

GOAL: leave the repo honest and a build a human can play.

1. Run the full harness; capture verbatim output.
2. Export a Windows build and RUN it headless with --quit-after 60 to confirm it
   boots with exit 0. A file existing is not a game booting.
3. Write runs/<UTC timestamp>.md per AGENTS.md §7.4 — attempted, gate output,
   refused and why, half-done, what the next run picks up. It is a log; nothing
   may cite it as authority.
4. End it with a PLAYTEST NOTE in plain language: how to launch, what is new
   tonight, what to try, what is knowingly rough. Do not oversell — he will find
   the rough edges anyway and an honest note costs him less time.
5. Commit. Do not push, do not touch main.

Findings from the completeness critic, to record in the journal rather than fix:
${JSON.stringify(critic, null, 2)}`, {
  label: 'report:journal', phase: 'Report', model: 'sonnet', effort: 'high',
  schema: {
    type: 'object',
    required: ['suite_output', 'build_ok', 'journal_path', 'playtest_note'],
    properties: {
      suite_output: { type: 'string' },
      build_ok: { type: 'boolean' },
      journal_path: { type: 'string' },
      playtest_note: { type: 'string' },
      next_run_should: { type: 'string' },
    },
  },
})

const greens = done.filter(Boolean).filter(s => s.status === 'green').length

return {
  phase: 'Phase 4 — Act I',
  steered_by: STEER || 'self-directed',
  slices: done.filter(Boolean).map(s => ({ slice: s.slice, status: s.status, notes: s.notes })),
  green: `${greens}/${slices.length}`,
  critic: critic || 'critic agent died',
  build: report ? report.build_ok : 'report agent died',
  journal: report ? report.journal_path : null,
  playtest_note: report ? report.playtest_note : null,
  gate_met: false,
  why_gate_not_met: 'The Phase 4 gate is a fresh install played start to finish in 3-5 hours by three external playtesters. No number of runs produces that; it needs a finished act and human testers.',
  next: report ? report.next_run_should : 'Run phase4-act-one again — it resumes from what exists.',
}
