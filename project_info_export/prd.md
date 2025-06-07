# Product Requirements Document (PRD): Depths of the Bastard God

---

## 1. Introduction & Vision

**Project Title:** Depths of the Bastard God

**Vision:** To deliver a console-quality, free-exploration Gothic horror game exclusively for the mobile platform. "Depths of the Bastard God" combines the oppressive atmosphere of classic horror titles with the replayability of modern roguelikes, all built around a non-linear, quest-driven world. The entire experience is procedurally generated and tailored for landscape-oriented, touch-based play.

## 2. Target Audience

-   **Primary:** Core mobile gamers who enjoy challenging action RPGs and horror games (e.g., fans of Dead Cells, Pascal's Wager, or mobile versions of "Souls-like" games).
-   **Secondary:** Fans of Gothic horror aesthetics (Castlevania, Bloodborne) looking for a deep, atmospheric experience on the go.

## 3. Platform & Technical Requirements

### 3.1. CRITICAL Platform Mandates
-   **Target OS:** Android
-   **Device Type:** Mobile phones
-   **Screen Orientation:** **LANDSCAPE ONLY.** The game must not support portrait mode.
-   **Input Method:** **TOUCH CONTROLS ONLY.** There will be no keyboard, mouse, or controller support until explicitly requested as a future development goal.
-   **Target Resolution:** Optimized for 1920x1080 landscape, with a flexible UI that scales cleanly to common mobile aspect ratios.

### 3.2. Engine & Rendering
-   **Game Engine:** Godot 4.4
-   **Perspective:** 3D Orthogonal ("2.5D") with a fixed camera angle of approximately 45 degrees.
-   **Renderer:** Godot's Mobile renderer.
-   **Texture Compression:** Must use mobile-optimized formats (ETC2/ASTC).

### 3.3. Performance Targets
-   **Framerate:** A stable 60 FPS on mid-range Android devices.
-   **Memory Usage:** Under 1.5GB of RAM.
-   **Generation Speed:** Procedural generation of a new room/area must take less than 1 second.
-   **Input Latency:** Touch input latency must be under 50ms.
-   **Battery Life:** Optimized to allow for at least 2 hours of continuous play.

## 4. Key Features & Gameplay

### 4.1. World Structure & Exploration
-   **Non-Linear World:** The game world is a persistent, interconnected web of areas. Progression is not linear.
-   **Quest-Driven Progression:** A robust questing system will guide players through the world, often requiring them to backtrack to previous areas to unlock new paths or secrets.
-   **Persistent State:** The game must save the state of the entire world, including defeated bosses, unlocked shortcuts, and major environmental changes.

### 4.2. Procedural Generation
-   A hybrid approach will be used. The main world will be handcrafted, while key gameplay areas will be procedurally generated to enhance replayability. This includes:
    -   **Dungeon Layouts:** The internal structure of dungeons and other special zones.
    -   **Enemy Encounters:** Placement and composition of a subset of enemy types within procedural areas.
    -   **Loot Distribution:** Randomized placement of items and resources within dungeons.
-   All procedural generation must be rule-based to ensure a coherent and intentional feel.

### 4.3. Sanity System
-   A core mechanic where the player's Sanity level directly affects gameplay.
-   Sanity decreases when encountering specific enemies or witnessing horrific events.
-   Low sanity will trigger:
    -   Visual and auditory hallucinations (false enemies, distorted sounds).
    -   Negative gameplay modifiers.
    -   Changes to the environment.

### 4.4. Combat System
-   Real-time action combat.
-   **Player Abilities:**
    -   **Stamina-Based Actions:** Attacking, dodging, and other core actions consume a stamina resource.
    -   **Committed Attacks:** Attack animations are weighty and cannot be easily canceled, demanding careful timing.
    -   **Dodge Roll:** A stamina-dependent defensive maneuver with i-frames.
    -   Equippable special weapons and abilities with unique, heavy attack patterns.
-   **Status Effects:** The system must support impactful effects like Bleed (burst damage), Corruption, Madness, Poison, and Curse for both players and enemies.

### 4.5. Player Progression
-   **Blood Echoes Economy:** The primary currency dropped by enemies, used for shops and upgrades.
-   **Black Market:** A special vendor that accepts **Sanity** as payment instead of Blood Echoes, offering a high-risk, high-reward trade-off.
-   **Mutation System:** A system for permanent character upgrades that provide powerful visual and mechanical changes. Players are limited to a small number of mutations per run to encourage strategic choices.

## 5. User Interface (UI) & User Experience (UX)

### 5.1. Controls
-   **Movement:** A dynamic virtual joystick on the left side of the screen.
-   **Actions:** A cluster of action buttons on the right side of the screen (Attack, Dodge, Interact, Abilities).
-   All buttons must have large tap targets and provide clear visual feedback.

### 5.2. Heads-Up Display (HUD)
-   The HUD must be clean, unobtrusive, and clearly legible on mobile screens.
-   **Required Elements:** Health Bar, Sanity Bar, Blood Echoes count, and a Pause/Menu button.
-   Equipped weapons/mutations should be displayed with clear icons.

### 5.3. Style & Aesthetics
-   **Art Style:** Dark, atmospheric Gothic horror, incorporating elements of cosmic dread and blasphemous religious iconography.
-   **Color Palette:** Primarily desaturated tones with strong accent colors (crimson, gold, sickly green) for important gameplay elements.
-   **Typography:** Thematic but highly readable fonts. 