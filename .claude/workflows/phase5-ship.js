export const meta = {
  name: 'phase5-ship',
  description: 'Phase 5: the technical half of shipping — performance, PC input, and builds from CI. The commercial half cannot be delegated.',
  whenToUse: 'ROADMAP.md Phase 5, once Act I is playable start to finish. Most of this phase is blocked on things no agent may do; run it to close the part that is not.',
  phases: [
    { title: 'Audit', detail: 'Measure what actually ships today rather than assuming' },
    { title: 'Technical', detail: 'Performance, input, and export from CI' },
    { title: 'Handoff', detail: 'State precisely what only a human can finish' },
  ],
}

// Phase 5 is the phase where being autonomous stops being the constraint.
//
// The technical half is ordinary work: a performance pass against the mobile
// budget, gamepad and keyboard input through the existing input manager, and an
// export pipeline that produces both builds from CI reproducibly.
//
// The other half is not slow, it is forbidden. Creating store accounts,
// handling signing keys, setting a price, publishing a page — AGENTS.md §7.1
// puts every one of those in the always-stop tier, and no authorisation given
// in a chat changes what an agent should be doing with a signing key. This
// workflow does the first half properly and hands over the second half with
// enough precision that the human half takes an evening rather than a week.

const REPO = 'C:\\Users\\jovy2\\Projects\\DotBG'

const PREAMBLE = `
Repository: ${REPO}. Godot 4.7 project is dotbg/; res:// is that directory.

READ FIRST: CANON.md (§4 for the mobile budget, §7 for platform), AGENTS.md,
ROADMAP.md.

HARNESS:
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1

Export templates for 4.7.1 are installed. dotbg/export_presets.cfg exists with a
Windows Desktop preset. Godot is NOT on PATH — resolve it the way
tools/run_tests.ps1 does.

HARD RULES from AGENTS.md §7, and §7.1's always-stop tier especially:
- NEVER create an account of any kind.
- NEVER handle, generate, or configure a signing key or keystore password.
- NEVER publish anything, set a price, or modify a store listing.
- NEVER spend money or make first use of a paid service.
- Never push, never touch main, never edit the binding documents.
These are not slowed down by needing permission — they are not yours to do at
all. Prepare them so a human can execute in minutes; then stop.

STANDARD OF DONE: measured, not estimated. A performance claim without a number
from a real run is exactly the kind of statement this project exists to distrust.
`

// ---------------------------------------------------------------- audit --

phase('Audit')

const audit = await agent(`${PREAMBLE}

GOAL: establish what actually ships today, with numbers.

- Export the Windows build, run it headless, confirm it boots with exit 0, and
  report its real size.
- Measure frame time for the busiest scene that exists, on this machine, over a
  meaningful sample. Report it as what it is: a desktop number on an integrated
  GPU. CANON.md §4 asks for 60 FPS, under 1.5 GB RAM and under 2 s generation on
  a mid-range Android, and this machine cannot answer that question.
- Report peak memory during that run against the 1.5 GB budget.
- Check the Android side honestly: is the SDK present, what does ANDROID_HOME
  say, what JDK is installed, and what does Godot 4.7 require? Report the gap;
  do not install anything yet.
- List every asset currently in dotbg/assets/ with its licence, from its sidecar.
  Anything shippable without attribution, anything requiring it, anything whose
  licence cannot be established. The last category is a shipping blocker and
  should be named as one.

Numbers, not adjectives.`, {
  label: 'audit:shippable', phase: 'Audit', model: 'sonnet', effort: 'high',
  schema: {
    type: 'object',
    required: ['build_ok', 'frame_time_ms', 'peak_memory_mb', 'android_gap', 'licence_risks'],
    properties: {
      build_ok: { type: 'boolean' },
      build_bytes: { type: 'number' },
      frame_time_ms: { type: 'string' },
      peak_memory_mb: { type: 'string' },
      android_gap: { type: 'string' },
      licence_risks: { type: 'array', items: { type: 'string' } },
    },
  },
})

// ------------------------------------------------------------ technical --

phase('Technical')

const WORK = [
  {
    key: 'perf',
    brief: `Performance pass against CANON.md §4: 60 FPS, under 1.5 GB RAM, under
2 s generation. Profile first and fix what the profile says, not what you expect
— the guess is usually the draw calls and the answer is usually something else.
Add an assertion to the suite that fails if frame time or peak memory regresses
past a threshold, so this cannot quietly rot. State the threshold you chose and
why.`,
  },
  {
    key: 'input',
    brief: `PC input: gamepad and keyboard/mouse, routed through
scripts/autoload/input_manager.gd exactly as touch is — AGENTS.md §4 forbids
reading raw input events in gameplay scripts, and a second input path is the
duplicate-source-of-truth defect this repo already had twice. Use the buffer
values in Tuning: INPUT_BUFFER_GAMEPAD and INPUT_BUFFER_TOUCH. Assert that the
same logical action arrives identically from all three input sources.`,
  },
  {
    key: 'ci-export',
    brief: `Get the Windows export running in GitHub Actions, producing a build
artefact on every push to the branch. Export templates are 1.2 GB per run, so
cache them by version key or use a prebuilt image; a workflow that redownloads
them every time will be turned off by whoever waits on it. The Phase 5 gate says
"reproducible from a clean clone" — prove that literally, by building from a
fresh checkout in CI rather than from a warm working tree. Do not add any step
that would need a secret.`,
  },
]

const results = []
for (const w of WORK) {
  const r = await agent(`${PREAMBLE}

Audit of what ships today:
${JSON.stringify(audit, null, 2)}

YOUR WORK: ${w.key}

${w.brief}

Run the harness until green. Commit when it is. If something here needs a
credential, a device or an account, stop at that line and report it — that is
the handoff, not a failure.`, {
    label: `tech:${w.key}`, phase: 'Technical', model: 'sonnet', effort: 'high',
    schema: {
      type: 'object',
      required: ['work', 'status', 'measurements', 'notes'],
      properties: {
        work: { type: 'string' },
        status: { type: 'string', enum: ['green', 'partial', 'blocked'] },
        measurements: { type: 'string', description: 'Before and after numbers where relevant' },
        blocked_on_human: { type: 'string' },
        notes: { type: 'string' },
      },
    },
  })
  results.push(r)
  log(`${w.key}: ${r ? r.status : 'agent died'}`)
}

// -------------------------------------------------------------- handoff --

phase('Handoff')

const handoff = await agent(`${PREAMBLE}

GOAL: make the human half of shipping take an evening instead of a week.

Write runs/<UTC timestamp>.md per AGENTS.md §7.4 covering tonight's technical
work, and then the part that matters most: a HANDOFF section listing every
remaining step that only a human can take, each one specific enough to act on
without research.

At minimum, and check the current state rather than copying this list:
- Google Play: developer account, the one-time fee, the AAB upload, the store
  listing, content rating, the privacy policy this game needs and why.
- Steam: partner account, the fee, the depot setup, capsule art dimensions.
- Signing: what keystore Android export needs, what must never enter the repo,
  and where dotbg/.gitignore already protects against it.
- The Android SDK and JDK gap the audit measured, with the exact versions.
- A physical mid-range Android device, which the Phase 3 performance gate has
  been waiting on since it was written.

For each: what it is, why an agent must not do it, roughly how long it takes,
and what it unblocks. Order them by what blocks the most.

Then state plainly which parts of the Phase 5 gate are met and which are not.
The gate is: shipped on both stores, with a build reproducible from a clean
clone. Half of that is engineering and half is commerce; say which half moved.

Commit the journal. Do not push.`, {
  label: 'handoff:human-steps', phase: 'Handoff', model: 'opus', effort: 'high',
  schema: {
    type: 'object',
    required: ['journal_path', 'human_steps', 'gate_engineering_met', 'gate_commercial_met'],
    properties: {
      journal_path: { type: 'string' },
      human_steps: { type: 'array', items: { type: 'string' } },
      gate_engineering_met: { type: 'boolean' },
      gate_commercial_met: { type: 'boolean' },
      summary: { type: 'string' },
    },
  },
})

return {
  phase: 'Phase 5 — ship',
  audit: audit || 'audit agent died',
  technical: results.filter(Boolean).map(r => ({ work: r.work, status: r.status, measurements: r.measurements })),
  handoff: handoff || 'handoff agent died',
  gate_met: false,
  why_gate_not_met: 'Shipping needs store accounts and signing keys. AGENTS.md §7.1 puts both in the always-stop tier, and that does not change with authorisation — an agent should not be creating accounts or handling signing keys regardless of who says it may.',
  next: 'The engineering half can be finished autonomously. The commercial half is the maintainer\'s, and the journal lists it step by step.',
}
