# Asset List: Depths of the Bastard God — Current Development Phase

> **Scope changed 2026-07-25.** Characters are now **3D models**, not 2D sprites
> — see `CANON.md` §1 and §5.4 for the reasoning. UI and debug art stay 2D.
> Filename kept for continuity; this list is no longer sprites-only.

## **PROJECT CONTEXT FOR ASSET CREATION**

### **Game Overview**
"Depths of the Bastard God" is a **3D Gothic horror action-adventure** featuring:
- **Full 3D** characters and environments, both modelled in Blender
- **Fixed orthogonal camera at ~45°** — Hades-style *perspective*, not Hades'
  2D art pipeline
- **Gothic cathedral environments**: authentic 3D cathedral architecture
- **Android + PC**, landscape orientation, touch and gamepad/KBM
- **Castlevania aesthetic**: Gothic horror with cathedral atmosphere

### **Technical Requirements**
- **Resolution target**: 1920x1080 landscape
- **Performance**: 60 FPS on mid-range Android
- **3D formats**: `.glb`/`.gltf` for meshes, PBR materials, ETC2/ASTC textures
- **2D formats**: PNG with transparency (UI and debug only)
- **Style**: Gothic horror, readable under a ~45° orthogonal camera

---

## **ESSENTIAL ASSETS FOR CURRENT DEVELOPMENT**

### **1. PLAYER CHARACTER — 3D (Priority 1)**
**Purpose**: validate character movement in 3D Gothic environments and confirm
the orthogonal camera framing.

**Replaces** the previous 10-sprite request. One model with a rig produces every
facing direction for free — the reason for the change is in `CANON.md` §5.4.

#### **Deliverables**
- `player.glb` — rigged humanoid, Gothic acolyte silhouette
  - target **8-15k tris** (mobile budget)
  - PBR material set, 1024×1024 albedo/normal/ORM max
  - humanoid skeleton compatible with retargeted animation
- Animation clips on that rig:
  - `idle`
  - `walk` (loop)
  - `run` (loop)
  - `dodge_roll`
  - `attack_primary`
  - `hit_react`
  - `death`

#### **Character Design Guidelines**
- **Gothic style**: dark palette, medieval, coherent with cathedral interiors
- **Camera readability**: silhouette must read from a ~45° orthogonal view — this
  is a stronger constraint in 3D than it was for sprites, since the model is seen
  from one fixed angle. **Prioritise silhouette over face detail.**
- **Colours**: deep blacks, burgundy reds, Gothic stone greys
- **Details**: Gothic clothing and armour elements; the protagonist is an
  **acolyte of a forgotten faith** (`CANON.md` §2) — vestment cues, not plate

---

### **2. VIRTUAL CONTROL UI — 2D (Priority 1)**
**Unchanged.** UI stays 2D regardless of the character pipeline.

#### **Virtual Joystick (2 sprites)**
- `joystick_base.png` — Gothic stone-styled circular base (96x96px)
- `joystick_stick.png` — Gothic metal-styled control stick (48x48px)

#### **Action Buttons (3 sprites)**
- `button_attack.png` — Gothic sword icon (64x64px)
- `button_dodge.png` — Gothic shield icon (64x64px)
- `button_interact.png` — Gothic hand/key icon (64x64px)

**UI Design Guidelines:**
- **Gothic materials**: stone textures, tarnished metal accents
- **Semi-transparency**: 70-80% opacity so 3D architecture stays visible
- **Candlelight effects**: subtle warm glow highlights
- **Mobile touch**: clear, easy-to-press visual feedback
- **Colour scheme**: stone greys, bronze/iron, warm amber highlights

---

### **3. DEBUG / TESTING — 2D (Priority 2)**
**Unchanged.**

- `debug_marker_red.png` — red circle, error indicator (32x32px)
- `debug_marker_green.png` — green circle, success indicator (32x32px)
- `debug_touch_point.png` — touch indicator with pulse (24x24px)

High contrast, simple geometry, functional over pretty.

---

### **4. CORRUPTION VALIDATION — shader, not asset (Priority 3)**
**Purpose**: test the sanity system against the 3D character.

**Replaces** `player_idle_corrupted.png` and `test_sprite_corrupted.png`. In 3D
the four corruption tiers in `CANON.md` §5 are a **material/shader pass over
existing geometry**, not separate art. That is the core reason for the pipeline
change — corruption stops being 4× the art and becomes one shader.

#### **Deliverable**
- `corruption.gdshader` — parameterised 0.0-1.0 corruption input driving the four
  tiers: surface roughening, colour desaturation toward sickly greens/purples,
  vertex displacement for the "breathing"/writhing effect, shadow decoupling.
  Applied to both character and environment materials.

---

## **CREATION PRIORITIES**

### **Phase 1: Player model + core locomotion**
`player.glb` with `idle`, `walk`, `run`

### **Phase 2: Virtual controls (5 sprites)**
`joystick_base`, `joystick_stick`, `button_attack`, `button_dodge`,
`button_interact`

### **Phase 3: Combat animation**
`dodge_roll`, `attack_primary`, `hit_react`, `death`

### **Phase 4: Debug + corruption validation**
Debug markers, then `corruption.gdshader`

---

## **TECHNICAL SPECIFICATIONS**

### **File Format & Organisation**
- **3D**: `.glb` (single-file, embedded textures), snake_case, under `assets/models/`
- **2D**: PNG with transparency, snake_case, under `assets/ui/` and `assets/debug/`
- **Compression**: ETC2/ASTC for mobile textures

### **Colour Palette** *(unchanged — canonical)*
- **Primary**: deep black `#1a1a1a`, stone grey `#4a4a4a`
- **Accent**: burgundy `#8b0000`, tarnished bronze `#cd7f32`
- **Highlights**: amber `#ffbf00`, candlelight `#fff8dc`
- **Corruption**: sickly green `#228b22`, otherworldly purple `#663399`

### **Quality Standards**
- Consistent art style across every asset
- Everything must sit naturally inside Gothic cathedral interiors
- Poly and texture budgets respected — 60 FPS, <1.5GB RAM

---

## **WHAT WE'RE NOT CREATING YET**
- ❌ Enemy models (not needed for current tasks)
- ❌ Weapon models
- ❌ Environmental detail meshes beyond a test space
- ❌ Multiple character variants
- ❌ Facial animation — the fixed camera does not justify it
- ❌ Full game content

---

## **SUCCESS CRITERIA**
1. A rigged character moves through a 3D Gothic space under the orthogonal camera
2. Virtual controls are Gothic-themed and legible over 3D architecture
3. The corruption shader visibly moves through its four tiers on real geometry
4. Development continues without asset-related blockers

**Strategic focus**: build only what the current phase needs. Prove the 3D concept
holds up under the fixed camera, then expand as tasks require.
