# ASSETS — lifecycle, naming and provenance

How every generated or authored asset enters, moves through and leaves this
project. Applies to **all asset types**: reference imagery, 3D models, textures,
rigs, animations, audio, shaders.

Subordinate to `CANON.md` for *what* the assets should look like. This file
governs *how they are handled*.

---

## 0. Why this exists

On 2026-07-25 a single evening of image generation produced three separate
silent failures: a tool reported "regenerated" while returning a byte-identical
copy, a file was copied from the wrong session, and a generated asset was
reported missing when it existed. None of them were visible without checking.

Three rules fall out of that, and everything below is machinery for them:

1. **An asset with no recorded provenance cannot be trusted or regenerated.**
2. **An asset that has not been hash-verified as distinct may be a duplicate.**
3. **If discarding is expensive, bad assets survive.** Deletion must be cheap.

---

## 1. Directory layout

```
art/
  prompts/       # the recipe for every generated asset — COMMITTED
  candidates/    # everything freshly generated — GITIGNORED
  approved/      # passed review; the only art the project may cite — COMMITTED
  rejected/      # sidecars only, never image bytes — COMMITTED

dotbg/assets/    # engine-consumed assets — COMMITTED
  models/
  textures/
  audio/
  shaders/
```

**Candidates are gitignored.** That is deliberate: generation is cheap and
noisy, and the repo should never carry the cost of exploration. Wiping
`art/candidates/` at any time must always be safe.

**`dotbg/assets/` may only ever contain approved work.** Nothing enters the
engine directly from `candidates/`.

---

## 2. Naming

```
<phase>-<seq>-<subject>[-<variant>].<ext>
```

- `phase` — the batch or milestone: `s1`, `s2`, `act1`, `boss-architect`
- `seq` — zero-padded order within the phase: `01`, `02`
- `subject` — kebab-case, descriptive: `hall-sanity75`, `acolyte-turnaround`
- `variant` — only when several candidates compete: `vA`, `vB`, `vC`

Examples:
```
s1-02-hall-sanity75-vA.png
s1-05-acolyte-turnaround.png
act1-column-pointed-arch.glb
boss-architect-phase2-ambience.ogg
```

Rules:
- **Never reuse a filename for different content.** A revision is a new
  `variant`, not an overwrite. Overwriting destroys the ability to compare.
- **No `_final`, `_new`, `_v2_real`, `_fixed`.** Status lives in the directory
  and the sidecar, never in the name.
- Lowercase and hyphens only. No spaces.

---

## 3. Provenance sidecar — mandatory

Every asset carries a sidecar with the same basename and `.json`:

```json
{
  "asset": "s1-02-hall-sanity75-vA.png",
  "sha256": "a2b7ac50d9...",
  "created": "2026-07-25T20:47:41Z",
  "tool": "codex-cli 0.129.0 / image_gen.imagegen",
  "prompt_file": "art/prompts/s1-02-hall-sanity75.md",
  "prompt_sha256": "bc2329e462...",
  "derived_from": null,
  "status": "candidate"
}
```

- `prompt_file` + `prompt_sha256` make the asset **reproducible**. If the prompt
  changes, the hash stops matching and the asset is known to be stale.
- `derived_from` carries lineage through the pipeline:
  reference image → mesh → retopologised mesh → rigged → engine-ready. Each step
  names its parent.
- `status` is one of `candidate`, `approved`, `rejected`, `superseded`.

**An asset without a sidecar is treated as untrusted and is deleted on sight.**

---

## 4. Lifecycle

```
generate → candidate → [review] → approved → (superseded)
                          └─────→ rejected
```

**candidate** — lives in `art/candidates/`. Gitignored. May be deleted at any
time without discussion.

**approved** — a human looked at it and said yes. Moves to `art/approved/`,
sidecar `status` set to `approved`, and it gets committed. Only approved assets
may be referenced by `CANON.md`, by the engine, or as a parent in `derived_from`.

**rejected** — **the bytes are deleted; the sidecar is kept** in `art/rejected/`
with a `reason` field added. This is the point of the whole scheme: we keep the
memory of what failed and why, so the same bad prompt is not run twice, without
paying storage for the failure.

```json
{ "asset": "s1-04-hall-sanity00-vB.png", "status": "rejected",
  "reason": "lost the cathedral silhouette entirely; CANON.md §5 requires the room stay recognisable at 0%" }
```

**superseded** — was approved, later replaced. Sidecar gains
`superseded_by: "<new asset>"`. Bytes deleted, sidecar kept. Same logic as
rejected: the record is cheap, the file is not.

---

## 5. Verification — required before any asset is presented as done

Generation tools fail silently. Every generated asset must clear all three
checks before it is shown to a human or moved out of `candidates/`:

1. **It exists**, at the expected path, with non-zero size.
2. **Its hash is unique** among sibling assets. A collision means the generator
   returned a cached or copied file rather than generating.
3. **A counter incremented** — the tool's own output directory grew by exactly
   the number of assets requested.

```bash
# uniqueness check
cd art/candidates && md5sum *.png | awk '{print $1}' | sort | uniq -d
# any output at all means a duplicate slipped through
```

Never rely on the generating tool's self-report. It has been wrong.

---

## 6. Discarding — must stay cheap

```bash
# drop every candidate, keep prompts and approved work
rm -rf art/candidates/*

# reject one candidate: keep the record, drop the bytes
python tools/reject_asset.py s1-04-hall-sanity00-vB.png --reason "..."
```

If a review round leaves more than a handful of candidates undecided, **discard
them all and regenerate later**. Undecided assets are the ones that quietly
become "maybe" forever. Regeneration costs cents; ambiguity costs months.

---

## 7. Rules for agent sessions

Binding, alongside `AGENTS.md`:

- Write generated output to `art/candidates/` only. Never write directly to
  `art/approved/` or `dotbg/assets/`.
- Never mark an asset `approved`. Only a human does that.
- Always write the sidecar in the same step that produces the asset. An asset
  without provenance is worse than no asset.
- Run the §5 verification and report the actual hashes. Do not claim an asset
  was generated without showing the evidence.
- Never overwrite an existing asset filename. Add a variant.
- When several agents write to the same folder concurrently, each must own a
  distinct variant suffix and touch nothing else.

---

## 8. Git policy

| Path | Tracked | Why |
|---|---|---|
| `art/prompts/` | yes | tiny, and the recipe for everything |
| `art/candidates/` | **no** | noisy, large, disposable by design |
| `art/approved/` | yes | the decisions worth keeping |
| `art/rejected/` | yes (sidecars only) | the memory of what failed |
| `dotbg/assets/` | yes | the game |

Approved reference images run 2-3 MB each. Once `art/approved/` plus
`dotbg/assets/` passes roughly 100 MB, move binary assets to **Git LFS** rather
than letting clone time degrade. Revisit at that threshold, not before.
