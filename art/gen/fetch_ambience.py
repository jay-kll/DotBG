"""Fetches CC0 ambience from Freesound. Requires an API key you must obtain.

    set FREESOUND_API_KEY=...
    python art/gen/fetch_ambience.py --query "cathedral reverb" --slug cathedral-tail

Placeholder SFX are synthesised locally by placeholder_sfx.py, with no network
and no licence. Ambience is the class that cannot be synthesised — cathedral
reverb tails, wind, dripping water, distant bells, whispers, drones — so it is
sourced instead, and Freesound with a CC0 filter is the one library that is
both deep enough and scriptable.

Two things make this safe to run unattended once the key exists:

  - **CC0 only.** The search is filtered to Creative Commons 0 and every result
    is re-checked before it is written. Freesound is a mixed-licence library:
    an unfiltered pull would quietly drag CC-BY or sampling-plus files into a
    commercial game, which is the exact trap that ruled out OpenGameArt.
  - **Previews, not originals.** Preview URLs are plain public GETs. Only the
    original full-quality file needs OAuth, which needs a browser, which is not
    automatable. Preview quality is more than enough for placeholder ambience.

The API key needs one human signup at https://freesound.org/apiv2/apply — an
agent cannot create the account, so this script refuses to guess and says so.
"""

import argparse
import hashlib
import json
import os
import sys
import urllib.parse
import urllib.request

API = "https://freesound.org/apiv2"
CC0 = 'license:"Creative Commons 0"'
OUT_REL = os.path.join("dotbg", "assets", "audio", "ambience")


def die(message, code=2):
    print("FAIL: " + message)
    sys.exit(code)


def get_json(url, key):
    request = urllib.request.Request(url, headers={"Authorization": "Token %s" % key})
    with urllib.request.urlopen(request, timeout=45) as response:
        return json.loads(response.read().decode("utf-8"))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--query", required=True, help="what to search for")
    parser.add_argument("--slug", required=True, help="filename stem to write")
    parser.add_argument("--min-duration", type=float, default=4.0)
    parser.add_argument("--max-duration", type=float, default=90.0)
    args = parser.parse_args()

    key = os.environ.get("FREESOUND_API_KEY", "").strip()
    if not key:
        die("FREESOUND_API_KEY is not set.\n"
            "      A human has to create the account and request the key:\n"
            "        https://freesound.org/apiv2/apply\n"
            "      Then set FREESOUND_API_KEY and re-run. This script will not\n"
            "      guess, and an agent cannot sign up on your behalf.")

    query = urllib.parse.urlencode({
        "query": args.query,
        "filter": '%s duration:[%s TO %s]' % (CC0, args.min_duration, args.max_duration),
        "fields": "id,name,license,previews,username,url,duration",
        "page_size": 10,
        "sort": "rating_desc",
    })
    results = get_json("%s/search/text/?%s" % (API, query), key).get("results", [])
    if not results:
        die("no CC0 result for %r" % args.query, code=1)

    # Re-check the licence on the object rather than trusting the filter. A
    # filter typo returns a full page of results that merely look right.
    chosen = None
    for candidate in results:
        if "creativecommons.org/publicdomain/zero" in candidate.get("license", ""):
            chosen = candidate
            break
    if chosen is None:
        die("results came back but none are CC0 on inspection; refusing to write", code=1)

    preview = chosen["previews"].get("preview-hq-mp3") or chosen["previews"].get("preview-lq-mp3")
    if not preview:
        die("no public preview URL on the chosen sound", code=1)

    repo = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    out_dir = os.path.join(repo, OUT_REL)
    os.makedirs(out_dir, exist_ok=True)
    audio_path = os.path.join(out_dir, "%s.mp3" % args.slug)

    with urllib.request.urlopen(preview, timeout=120) as response:
        payload = response.read()
    if len(payload) < 2048:
        die("preview download is implausibly small (%d bytes)" % len(payload), code=1)
    with open(audio_path, "wb") as handle:
        handle.write(payload)

    sidecar = {
        "asset": os.path.basename(audio_path),
        "sha256": hashlib.sha256(payload).hexdigest(),
        "bytes": len(payload),
        "source": chosen["url"],
        "source_id": chosen["id"],
        "source_name": chosen["name"],
        "uploader": chosen["username"],
        "duration_seconds": round(chosen.get("duration", 0.0), 3),
        "license": chosen["license"],
        "attribution_required": False,
        "commercial_use": True,
        "quality": "preview-hq-mp3 — the original needs OAuth, which needs a browser",
        "search_query": args.query,
        "status": "candidate",
        "note": "Placeholder ambience. Only a human approves it into art/approved/, per ASSETS.md §4.",
    }
    with open(os.path.join(out_dir, "%s.json" % args.slug), "w", encoding="utf-8") as handle:
        json.dump(sidecar, handle, indent=2)
        handle.write("\n")

    print("  wrote %s (%d bytes, %.1f s)" % (audio_path, len(payload), sidecar["duration_seconds"]))
    print("  licence: %s" % chosen["license"])
    print("  source:  %s" % chosen["url"])
    print("RESULT: PASS")


if __name__ == "__main__":
    main()
