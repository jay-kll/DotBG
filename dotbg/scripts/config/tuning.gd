class_name Tuning
extends RefCounted

## The signed numeric contract for how this game feels.
##
## Approved 2026-07-25. These are not defaults to drift from — they are the
## agreed values, and `tests/tuning_test.gd` asserts them so a change has to be
## deliberate rather than accidental. Nothing else in the codebase may declare a
## competing movement, stamina or timing constant; there was already a `speed`
## in `player_3d.gd` and a `base_speed` in `player_stats.gd`, both 200.0, both
## claiming to be the answer.
##
## Why this file exists at all: "tune the movement" and "stamina-gated combat"
## are not assertable. An agent can set a number, watch a test pass, and have
## proved nothing. With the numbers fixed in advance the work becomes mechanical
## and checkable, which is what makes Phases 1 and 2 safe to run unattended.
##
## Units are metres and seconds. The player capsule is 2 m tall. The old values
## were 2D pixels-per-second (200.0 read as 720 km/h on a 2 m body), which is
## the single loudest symptom of the abandoned 2D branch.
##
## Anchors, where sources exist: dodge invincibility is measured at 12–13 frames
## at 30 fps in Dark Souls 3, i.e. 400–433 ms. We sit deliberately above that
## range because a virtual joystick gives no tactile feedback and a touch player
## commits later than a gamepad player. Stamina costs are expressed against a
## pool of 100 so they read directly as percentages; DS3's light attack runs
## 12–21% of pool depending on Endurance, and 20% puts us at the punishing end,
## which is the stated intent.
##
## Run speed, the invincibility window and the attack commitment window are the
## three a playtest decides, not a test. Everything else is arithmetic around
## them. See CANON.md §1 for the combat model these serve.

# ---------------------------------------------------------------- movement --

## Deliberate, weighted. Slower than a human walk on purpose.
const WALK_SPEED := 1.6
## Free — no stamina cost, as in the Souls family. There is deliberately no
## third sprint speed: on a virtual joystick a hidden third state is a mode.
const RUN_SPEED := 3.6
const TIME_TO_FULL_SPEED := 0.12
const TIME_TO_STOP := 0.10

## Godot wants acceleration in m/s². Derived so the constants above stay the
## thing a human edits.
static func acceleration() -> float:
	return RUN_SPEED / TIME_TO_FULL_SPEED

static func deceleration() -> float:
	return RUN_SPEED / TIME_TO_STOP

# ------------------------------------------------------------------- dodge --

## Invincible window. Above the DS3-measured 400–433 ms, for touch.
const DODGE_IFRAMES := 0.45
## Whole animation. The difference between this and the invincible window is
## the vulnerable recovery tail, and that tail is the entire Soulslike
## commitment — without it this is Hades.
const DODGE_TOTAL := 0.75
## Roughly 1.6 body lengths: enough to leave a melee arc at the canonical camera.
const DODGE_DISTANCE := 3.2
const DODGE_STAMINA := 25.0

## All travel happens inside the invincible window, so the roll reads as a
## burst followed by a moment of being stuck, rather than a long glide.
static func dodge_recovery() -> float:
	return DODGE_TOTAL - DODGE_IFRAMES

static func dodge_speed() -> float:
	return DODGE_DISTANCE / DODGE_IFRAMES

# ----------------------------------------------------------------- stamina --

const STAMINA_MAX := 100.0
const STAMINA_REGEN := 30.0
## Without a pause before regeneration, stamina stops being a resource.
const STAMINA_REGEN_DELAY := 0.6

const STAMINA_LIGHT_ATTACK := 20.0
const STAMINA_HEAVY_ATTACK := 35.0
const STAMINA_PARRY := 15.0

## An action cannot start at zero stamina, but one that starts may drive the
## pool negative. That is the Souls bargain: you are allowed to make the
## mistake, and then you pay for it.
const STAMINA_ALLOW_OVERDRAW := true

# ------------------------------------------------------------------ attacks --

const LIGHT_WINDUP := 0.25
const LIGHT_ACTIVE := 0.10
const LIGHT_RECOVERY := 0.35

const HEAVY_WINDUP := 0.55
const HEAVY_ACTIVE := 0.12
const HEAVY_RECOVERY := 0.50

## Time from committing to the swing until input is accepted again. Nothing
## cancels it. This number is the combat model.
static func light_commitment() -> float:
	return LIGHT_WINDUP + LIGHT_ACTIVE + LIGHT_RECOVERY

static func heavy_commitment() -> float:
	return HEAVY_WINDUP + HEAVY_ACTIVE + HEAVY_RECOVERY

# ------------------------------------------------------------------- health --

const HEALTH_MAX := 100.0
## Five hits from a basic enemy. Punishing without being arbitrary.
const BASIC_ENEMY_DAMAGE := 20.0

# ------------------------------------------------------------------- sanity --

const SANITY_MAX := 100.0
## No passive drain. A per-second drip turns Act I into a clock, and CANON.md §5
## describes sanity as something the player spends, not something that leaks.
const SANITY_PASSIVE_DRAIN := 0.0

const SANITY_ELDRITCH_DAMAGE := 8.0
const SANITY_FORBIDDEN_TEXT := 12.0
const SANITY_WITNESS_HORROR := 15.0

## The four visual corruption tiers of CANON.md §5, as the thresholds that
## drive them. 100 is crisp stone; 0 is non-Euclidean nightmare.
const SANITY_TIERS := [100.0, 75.0, 50.0, 0.0]

# -------------------------------------------------------------------- input --

const INPUT_BUFFER_GAMEPAD := 0.20
## Touch commits later and less precisely, so it buffers longer.
const INPUT_BUFFER_TOUCH := 0.25
## Android accessibility guidance minimum for a touch target.
const MIN_TOUCH_TARGET_DP := 48
