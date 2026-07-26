export const meta = {
  name: 'phase3-art-pipeline',
  description: 'Phase 3: parametric Gothic kit, corruption shader on real geometry, and a room that replaces the primitive box',
  whenToUse: 'ROADMAP.md Phase 3, after phase2-core-loop reports its gate green. This is the roadmap\'s stated bottleneck.',
  phases: [
    { title: 'Design', detail: 'Kit dimensions, grid module and the piece list', model: 'fable' },
    { title: 'Kit', detail: 'One Blender generator per piece — strictly sequential, the machine cannot overlap them' },
    { title: 'Assemble', detail: 'Build a room from the kit and put the corruption shader on real geometry' },
    { title: 'Verify', detail: 'Seams, budgets, drift, and whether it reads as Gothic' },
    { title: 'Gate', detail: 'Report honestly, including the part no agent can measure' },
  ],
}

// Phase 3 is where everything before this ran on primitives and everything after
// depends on throughput proven here. The capability audit already established
// that the pipeline works end to end: parametric geometry reaches Godot with
// exact dimensions, UVs and materials, the corruption shader compiles and
// visibly moves pixels, rigging survives, and CC0 material can be sourced and
// licence-checked. What is unproven is whether it produces a room worth looking
// at, and that is a human's call.
//
// The gate has a part no agent can satisfy: 60 FPS measured on a physical
// mid-range Android. There is no device and no SDK. This workflow reports that
// as unmet rather than quietly redefining the gate around what it can reach.

const REPO = 'C:\\Users\\jovy2\\Projects\\DotBG'

const PREAMBLE = `
Repository: ${REPO}. Godot 4.7 project is dotbg/; res:// is that directory.

READ FIRST: CANON.md (especially §5 art direction and §5.4 on why this is full
3D), AGENTS.md, ROADMAP.md and ASSETS.md. Then read art/gen/probe_arch.py — it
is the worked example of everything below.

HARNESSES:
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_golden.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/blender.ps1 -Script <path>

WHAT THE AUDIT ALREADY PROVED, so you do not rediscover it:
- Blender operators do not work headless. solidify on an edge-only mesh yields
  zero polygons; uv.smart_project has no context without a window. Build mesh
  data and analytic UVs directly. Analytic UVs are better anyway — texel density
  fixed by construction is what keeps stonework continuous across a seam.
- Blender is Z-up, Godot is Y-up, and glTF converts on export. The failure mode
  is an arch lying on its back that still passes a "did it import" check.
- Blender 4.4 replaced Action.fcurves with slotted actions. Look the API up
  against 5.2 rather than recalling it.
- Approved CC0 stone material is at dotbg/assets/materials/bricks089/.
  art/gen/fetch_ambience.py shows the pattern for sourcing more, CC0-filtered
  and re-checked per file.

HARD RULES from AGENTS.md §7:
- NEVER two heavy jobs at once. ~1GB RAM free, integrated GPU. Blender runs one
  at a time with the Godot editor closed; tools/blender.ps1 enforces this and
  passing -Force to defeat a guard that is telling the truth is not allowed.
- NEVER mark an asset approved, and never judge that something looks Gothic.
  Render it, put it in the queue, and say what you measured. ASSETS.md §4.
- Never edit CANON.md, AGENTS.md, ASSETS.md, ROADMAP.md.
- Never push, never touch main. Check for a STOP file between units.
- Commit each piece when its assertions pass. Conventional Commits, WHY in the
  body, ending: Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>

STANDARD OF DONE: a generator is finished when a test asserts the geometry it
produced — dimensions to the millimetre, closed mesh, UVs present, tri budget —
and the suite is green. "It exported" is not done; an empty 180-byte glTF
exported once here and passed a size check.
`

const PIECE = {
  type: 'object',
  required: ['piece', 'status', 'tris', 'dimensions', 'suite_output'],
  properties: {
    piece: { type: 'string' },
    status: { type: 'string', enum: ['green', 'partial', 'blocked'] },
    tris: { type: 'number' },
    dimensions: { type: 'string' },
    suite_output: { type: 'string' },
    notes: { type: 'string' },
  },
}

// --------------------------------------------------------------- design --

phase('Design')

const design = await agent(`${PREAMBLE}

GOAL: the dimensional contract for a modular Gothic kit, so every piece built
afterwards tiles with every other piece without anyone adjusting anything.

Write no generators. Decide and justify:

- The GRID MODULE. One number that every piece is a multiple of. Everything
  downstream depends on this being right, and changing it later invalidates
  every built piece.
- Wall height, floor thickness, arch span and rise, column diameter — all
  expressed against the module and against the 2 m player capsule. An arch the
  player cannot walk under is the obvious failure; an arch that makes the player
  look like a toy is the subtle one, and this camera is fixed at 45° orthogonal
  so proportion reads immediately.
- Triangle budget per piece class, derived from the mobile target in CANON.md §4
  and from how many pieces a room contains.
- SEAM RULE: where exactly two pieces meet, and what must be true of the
  vertices there for the join to be invisible at the canonical camera.
- Subdivision density. The corruption shader displaces vertices along normals;
  a piece with too few evenly-spaced vertices cannot deform at the lower sanity
  tiers. Say what minimum density each piece class needs and why.
- The piece list for a first room: floor, wall, pointed arch, column, ribbed
  vault, and any trim. Order them by how much everything else depends on them.

Return a specification an implementer follows literally.`, {
  label: 'design:kit', phase: 'Design', model: 'fable', effort: 'high',
})

// ------------------------------------------------------------------ kit --

phase('Kit')

const PIECES = ['floor', 'wall', 'pointed_arch', 'column', 'ribbed_vault']
const built = []

// Strictly sequential. These are independent files and would parallelise
// beautifully on a machine with memory; this one has about a gigabyte free and
// two concurrent Blender processes will thrash swap until the night is gone.
for (const piece of PIECES) {
  const result = await agent(`${PREAMBLE}

APPROVED KIT DESIGN — follow its numbers exactly:
--- BEGIN ---
${design}
--- END ---

YOUR PIECE: ${piece}

Write art/gen/kit_${piece}.py following the pattern in art/gen/probe_arch.py:
mesh data and analytic UVs, no operators, exact dimensions, exported into
dotbg/assets/kit/.

Extend dotbg/tests/kit_test.gd (create it if it does not exist) with assertions
for this piece: it imports, its dimensions match the design to within 5 mm, its
triangle count is inside budget, it has UVs, its mesh is closed, and its
vertices sit on the grid module. If a kit_test.gd already exists, add to it
rather than replacing what is there.

Then run the harness until green and commit.`, {
    label: `kit:${piece}`, phase: 'Kit', model: 'sonnet', effort: 'high', schema: PIECE,
  })
  built.push(result)
  log(`${piece}: ${result ? `${result.status}, ${result.tris} tris, ${result.dimensions}` : 'agent died'}`)
}

// ------------------------------------------------------------- assemble --

phase('Assemble')

const room = await agent(`${PREAMBLE}

KIT DESIGN:
--- BEGIN ---
${design}
--- END ---

GOAL: replace the primitive test box with a room built from the kit, and put the
corruption shader on real geometry for the first time.

- Assemble dotbg/scenes/rooms/chapel.tscn from the generated kit pieces, snapped
  to the grid module. It does not need to be beautiful; it needs to be correct
  and to contain at least one instance of every piece.
- Apply shaders/corruption.gdshader to the kit geometry, wired so a single sanity
  value drives the whole room.
- Make it the scene GameManager loads, so the player from Phase 2 stands in it.
- Extend the golden harness to render the chapel at sanity 1.0, 0.66, 0.33 and
  0.0 — the four tiers of CANON.md §5. Write them to art/golden/current/. Do NOT
  approve them; a human does that.
- Assert seams programmatically: for every pair of adjacent pieces, vertices
  within epsilon across the join. A seam that opens is the exact silent failure
  the golden harness exists to catch, and a number catches it earlier than an
  eye does.

Run both harnesses. Commit when green.`, {
  label: 'assemble:chapel', phase: 'Assemble', model: 'sonnet', effort: 'high', schema: PIECE,
})

// --------------------------------------------------------------- verify --

phase('Verify')

const LENSES = [
  { key: 'seams', brief: 'Do the pieces actually tile? Check the seam assertions exist and are real — that they compare actual vertex positions across an actual adjacency, not that two numbers from the same constant match. Try mis-snapping a piece by a millimetre and confirm the assertion catches it, then revert.' },
  { key: 'budget', brief: 'Triangle counts, texture memory and draw calls against the mobile target in CANON.md §4. A room that only runs on a desktop is not a room. State the totals for the assembled chapel, not per piece.' },
  { key: 'shader', brief: 'Does the corruption shader deform the kit geometry at low sanity, or only recolour it? A piece with insufficient vertex density will change colour and not shape, which reads as flat and defeats CANON.md §5. Compare the four rendered tiers and report the measured difference between each pair, not just between the extremes.' },
]

const verdicts = (await parallel(LENSES.map(l => () => agent(`${PREAMBLE}

Review the kit and chapel just committed. Start with git log --oneline -8 and
git diff HEAD~6 --stat.

LENS: ${l.key}
${l.brief}

Adversarial and specific: file, line, and what you actually ran. Fix nothing.
Blocking means a human looking at this tomorrow would be misled.`, {
  label: `verify:${l.key}`, phase: 'Verify', model: 'opus', effort: 'high',
  schema: {
    type: 'object',
    required: ['dimension', 'blocking', 'findings'],
    properties: {
      dimension: { type: 'string' },
      blocking: { type: 'boolean' },
      findings: { type: 'array', items: { type: 'object', required: ['summary', 'severity'], properties: {
        summary: { type: 'string' }, file: { type: 'string' },
        severity: { type: 'string', enum: ['critical', 'major', 'minor'] }, evidence: { type: 'string' } } } },
    },
  },
})))).filter(Boolean)

const blocking = verdicts.filter(v => v.blocking)
if (blocking.length > 0) {
  await agent(`${PREAMBLE}

Fix these blocking findings and only these. Prove each with a harness run, or
explain with evidence why the reviewer was wrong — reviewers are sometimes
wrong. Commit when green.

${JSON.stringify(blocking, null, 2)}`, {
    label: 'verify:repair', phase: 'Verify', model: 'sonnet', effort: 'high', schema: PIECE,
  })
}

// ----------------------------------------------------------------- gate --

phase('Gate')

const gate = await agent(`${PREAMBLE}

GOAL: report the true state of the Phase 3 gate, including the part you cannot
satisfy.

The gate in ROADMAP.md reads: the primitive test box replaced by real Gothic
geometry with the real character in it, holding 60 FPS on a mid-range Android
device, with the corruption shader visibly sweeping 0 to 1. Measured, not
eyeballed.

Establish and report separately:
- Is the primitive box actually gone, and does the player stand in kit geometry?
- Does corruption sweep across all four tiers on that geometry? Give the measured
  difference between tiers, from the rendered images.
- What frame rate does the chapel hold in a headless-timed run on THIS machine?
  Report it as what it is — a desktop number on an integrated GPU, not the
  Android figure the gate asks for.
- The 60 FPS mid-range Android measurement CANNOT be produced: there is no
  device and no Android SDK. Say so plainly. Do not substitute a desktop number
  and call the gate met, and do not propose redefining the gate.

Then write runs/<UTC timestamp>.md per AGENTS.md §7.4, ending with a REVIEW NOTE
for the maintainer: which rendered images are waiting in art/golden/current/,
what to look at in each, and what you would want changed if it were your call —
phrased as an opinion offered, not a decision taken. Commit the journal.`, {
  label: 'gate:report', phase: 'Gate', model: 'opus', effort: 'high',
  schema: {
    type: 'object',
    required: ['box_replaced', 'corruption_sweeps', 'android_fps_measured', 'journal_path', 'review_note'],
    properties: {
      box_replaced: { type: 'boolean' },
      corruption_sweeps: { type: 'boolean' },
      tier_differences: { type: 'string' },
      desktop_fps: { type: 'string' },
      android_fps_measured: { type: 'boolean', description: 'Always false here — no device, no SDK' },
      journal_path: { type: 'string' },
      review_note: { type: 'string' },
    },
  },
})

return {
  phase: 'Phase 3 — art pipeline',
  pieces: built.filter(Boolean).map(p => ({ piece: p.piece, status: p.status, tris: p.tris })),
  chapel: room ? room.status : 'assemble agent died',
  blocking_findings: blocking.length,
  gate: gate || 'gate agent died',
  gate_met: false,
  why_gate_not_met: 'The 60 FPS mid-range Android measurement needs a physical device and the Android SDK. Everything else in the gate can be reported; that number cannot be produced by any agent on this machine.',
  next: 'A human reviews art/golden/current/ and approves or rejects. Aesthetic direction is not delegable. Then phase4-act-one.',
}
