# Sprite List: Depths of the Bastard God - Current Development Phase

## **PROJECT CONTEXT FOR SPRITE CREATION**

### **Game Overview**
"Depths of the Bastard God" is a **2.5D Gothic horror action-adventure** featuring:
- **2D sprites in 3D world** architecture (like Hades)
- **Hades-style perspective**: Orthogonal 3D camera at ~45° angle
- **Gothic cathedral environments**: Authentic 3D cathedral architecture
- **Mobile-first**: Android landscape orientation, touch controls
- **Castlevania aesthetic**: Gothic horror with cathedral atmosphere

### **Technical Requirements**
- **Resolution**: 1920x1080 landscape mobile
- **Performance**: 60 FPS on mid-range Android devices
- **Format**: PNG with transparency
- **Style**: Gothic horror aesthetic compatible with 3D cathedral environments
- **Perspective**: Designed for Hades-style ~45° orthogonal camera view

---

## **ESSENTIAL SPRITES FOR CURRENT DEVELOPMENT (16 sprites total)**

### **1. PLAYER CHARACTER SPRITES (Priority 1)**
**Purpose**: Test 2D sprite movement in 3D Gothic environments + validate Hades-style perspective

#### **Basic Movement Set (10 sprites)**
- `player_idle.png` - Single idle frame for testing (128x128px)
- `player_walk_01.png` - Walk cycle frame 1 (128x128px)
- `player_walk_02.png` - Walk cycle frame 2 (128x128px)
- `player_walk_03.png` - Walk cycle frame 3 (128x128px)
- `player_walk_04.png` - Walk cycle frame 4 (128x128px)
- `player_run_01.png` - Run cycle frame 1 (128x128px)
- `player_run_02.png` - Run cycle frame 2 (128x128px)
- `player_run_03.png` - Run cycle frame 3 (128x128px)
- `player_run_04.png` - Run cycle frame 4 (128x128px)
- `player_idle_corrupted.png` - Idle with sanity corruption effects (128x128px)

**Character Design Guidelines:**
- **Gothic Style**: Dark colors, medieval aesthetic compatible with cathedral environments
- **Hades Perspective**: Character must be readable from ~45° orthogonal view
- **Mobile Clarity**: Clear silhouette at mobile resolution
- **Animation**: Smooth movement that works in 3D Gothic spaces
- **Facing Direction**: Single direction (engine will flip for opposite)
- **Colors**: Deep blacks, burgundy reds, Gothic stone grays
- **Details**: Gothic clothing/armor elements, cathedral-appropriate design

---

### **2. VIRTUAL CONTROL UI SPRITES (Priority 1)**
**Purpose**: Complete Task 3 - Virtual Controls UI with Gothic-themed touch controls

#### **Virtual Joystick (2 sprites)**
- `joystick_base.png` - Gothic stone-styled circular base (96x96px)
- `joystick_stick.png` - Gothic metal-styled control stick (48x48px)

#### **Action Buttons (3 sprites)**
- `button_attack.png` - Gothic sword icon (64x64px)
- `button_dodge.png` - Gothic shield icon (64x64px)
- `button_interact.png` - Gothic hand/key icon (64x64px)

**UI Design Guidelines:**
- **Gothic Materials**: Stone textures, tarnished metal accents
- **Semi-Transparency**: 70-80% opacity to not obscure 3D Gothic architecture
- **Candlelight Effects**: Subtle warm glow highlights
- **Mobile Touch**: Clear, easy-to-press visual feedback
- **Cathedral Integration**: UI elements inspired by Gothic architectural details
- **Color Scheme**: Stone grays, bronze/iron metals, warm amber highlights

---

### **3. DEBUG/TESTING SPRITES (Priority 2)**
**Purpose**: Complete Task 2.12 Debug Tools + validate sprite system

#### **Debug Markers (3 sprites)**
- `debug_marker_red.png` - Simple red circle for error indicators (32x32px)
- `debug_marker_green.png` - Simple green circle for success indicators (32x32px)
- `debug_touch_point.png` - Visual touch indicator with pulsing effect (24x24px)

**Debug Design Guidelines:**
- **High Contrast**: Bright colors that stand out against Gothic environments
- **Simple Shapes**: Basic geometric forms for clear visibility
- **Minimal Style**: Clean, functional design for debugging purposes

---

### **4. BASIC VALIDATION SPRITE (Priority 3)**
**Purpose**: Test sanity system effects on 2D sprites

#### **Test Corruption (1 sprite)**
- `test_sprite_corrupted.png` - Simple test sprite with corruption effects (64x64px)

**Corruption Guidelines:**
- **Visual Distortion**: Subtle reality-bending effects
- **Gothic Horror**: Corruption that fits cathedral horror theme
- **Sanity Integration**: Effects that suggest mental instability

---

## **SPRITE CREATION PRIORITIES**

### **Phase 1: Essential Player Character (5 sprites)**
Create these first for immediate development needs:
1. `player_idle.png`
2. `player_walk_01.png` through `player_walk_04.png`

### **Phase 2: Virtual Controls (5 sprites)**
Create these for Task 3 completion:
1. `joystick_base.png`
2. `joystick_stick.png`
3. `button_attack.png`
4. `button_dodge.png`
5. `button_interact.png`

### **Phase 3: Debug & Testing (4 sprites)**
Create these for debug system completion:
1. `player_run_01.png` through `player_run_04.png`

### **Phase 4: Validation (2 sprites)**
Create these for system testing:
1. `player_idle_corrupted.png`
2. Debug markers and test sprites

---

## **TECHNICAL SPECIFICATIONS**

### **File Format & Organization**
- **Format**: PNG with transparency
- **Naming**: snake_case for consistency
- **Organization**: Organize by category (player/, ui/, debug/)
- **Compression**: Optimize for mobile without quality loss

### **Color Palette Guidelines**
- **Primary**: Deep blacks (#1a1a1a), Gothic stone grays (#4a4a4a)
- **Accent**: Burgundy reds (#8b0000), tarnished bronze (#cd7f32)
- **Highlights**: Warm amber (#ffbf00), candlelight yellows (#fff8dc)
- **Corruption**: Sickly greens (#228b22), otherworldly purples (#663399)

### **Quality Standards**
- **Resolution**: High enough for mobile clarity, optimized for performance
- **Consistency**: Unified art style across all sprites
- **Gothic Integration**: All sprites must feel natural in Gothic cathedral environments
- **Mobile Performance**: Optimized file sizes for 60 FPS gameplay

---

## **WHAT WE'RE NOT CREATING YET**
- ❌ Enemy sprites (not needed for current tasks)
- ❌ Complex animation sets (basic movement testing first)
- ❌ Environmental detail sprites (3D environment handles this)
- ❌ Multiple character variants (one character for testing)
- ❌ Weapon sprites (not in current task scope)
- ❌ Full game content sprites (way too early)

---

## **SUCCESS CRITERIA**
These sprites will enable us to:
1. ✅ Complete Task 2.12 (Debug Tools)
2. ✅ Complete Task 3 (Virtual Controls UI)
3. ✅ Validate 2D sprites in 3D world concept
4. ✅ Test basic sanity corruption effects
5. ✅ Continue development without sprite-related blockers

**Strategic Focus**: Create only what's needed for current development phase. Validate the 2.5D concept works beautifully, then expand sprite library as tasks require them. 