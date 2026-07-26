"""Generates placeholder sound effects. No network, no licence, no account.

    python art/gen/placeholder_sfx.py

Synthesised with pyfxr (BSD), the sfxr family of retro SFX generators. Nothing
is downloaded and nothing is licensed, so there is no attribution to track and
no per-file terms to audit before shipping.

Being obviously synthetic is the point. A placeholder that sounds like a real
recording quietly becomes the final sound because nobody notices it is
temporary; an sfxr bleep announces itself as scaffolding every time it plays.
Real sound design is Phase 4 — CANON.md §8 — and these exist so combat can be
built and tested with audible feedback before then.

Deterministic by seed, so a rerun produces the same bytes and the golden-image
discipline in ASSETS.md applies to audio too. Change SEED, not the clips, if
you want different ones.

What this cannot make: cathedral ambience, wind, dripping water, whispers,
drones. Synthesis of that class is out of reach here and it comes from CC0
libraries instead — Freesound's CC0 filter is the researched answer, and its
preview URLs need no OAuth, but obtaining the API key needs one human signup.
"""

import os
import random
import sys

import pyfxr

SEED = 20260725

# Mapped to what Phase 2 actually needs to hear while being built. The preset
# names are sfxr's vocabulary, not ours — "explosion" is the closest thing it
# has to a weapon connecting with a body.
CLIPS = {
    "player_hurt": pyfxr.hurt,
    "player_death": pyfxr.explosion,
    "attack_swing": pyfxr.laser,
    "attack_impact": pyfxr.explosion,
    "dodge_roll": pyfxr.jump,
    "echoes_pickup": pyfxr.pickup,
    "ui_select": pyfxr.select,
    "ui_confirm": pyfxr.pickup,
}

OUT_REL = os.path.join("dotbg", "assets", "audio", "placeholder")


def main():
    random.seed(SEED)
    repo = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    out_dir = os.path.join(repo, OUT_REL)
    os.makedirs(out_dir, exist_ok=True)

    print("=== placeholder_sfx: start ===")
    print("  pyfxr, seed %d, writing to %s" % (SEED, out_dir))

    failures = 0
    for name, generator in CLIPS.items():
        path = os.path.join(out_dir, "%s.wav" % name)
        buffer = generator().build()
        buffer.save(path)

        size = os.path.getsize(path) if os.path.exists(path) else 0
        # A zero-length clip is what a silently failed synth looks like: the
        # file exists, the name is right, and nothing is ever heard.
        ok = size > 44 and buffer.duration > 0.0
        if not ok:
            failures += 1
        print("  %s  %-16s %6.3f s  %6d bytes" % (
            "PASS" if ok else "FAIL", name, buffer.duration, size))

    print("=== placeholder_sfx: %d clips, %d failures ===" % (len(CLIPS), failures))
    print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
