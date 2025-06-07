# Feature Descriptions: Depths of the Bastard God

This document provides a detailed breakdown of the core features and systems that define the "Depths of the Bastard God" experience.

---

## 1. Free-Exploration World Structure

This is the foundational design pillar of the game, distinguishing it from linear "Soulsvania" titles.

-   **Non-Linear Progression:** Players are not funneled down a single, predetermined path. The world is a web of interconnected areas that can be explored in various orders.
-   **Quest-Driven Backtracking:** The quest system is the primary driver of progression. Quests will intelligently and intentionally guide players back to previously discovered areas to unlock new paths, encounter new events, or solve puzzles with newly acquired abilities or information.
-   **Persistent & Interconnected World:** Every area discovered by the player remains accessible throughout the game. The save system is designed to track the state of this complex world, including defeated bosses, unlocked shortcuts, and environmental changes. This persistence is critical for making the exploration feel meaningful.

---

## 2. Strategic Procedural Generation

The game leverages a hybrid design, blending a handcrafted, persistent world with procedurally generated elements to ensure replayability and unique challenges. This approach allows for a cohesive, non-linear quest structure within an ever-changing gameplay environment.

-   **Generated Content:** Procedural generation is focused on specific gameplay segments:
    -   **Dungeon Layouts:** While the main world map is fixed, the internal layouts of dungeons, crypts, and other special zones are procedurally generated for each run.
    -   **Enemy Placements & Subsets:** A selection of enemies will be procedurally placed within dungeons. Some enemy variations may also be generated with unique stats or abilities.
    -   **Loot & Resources:** The location and type of loot found within procedural areas are randomized.
-   **Handcrafted World:** The overarching world, key landmarks, quest locations, and the connections between areas are handcrafted. This ensures that the critical path for non-linear exploration and storytelling remains consistent and intentional.
-   **Mobile Performance Focus:** All procedural algorithms are designed to be lightweight and efficient, minimizing CPU/GPU load and memory usage to ensure a smooth 60 FPS experience on target Android devices.

---

## 3. Sanity System & Horror Mechanics

The Sanity system is a central mechanic that directly influences the player's perception of the game world, creating a constant sense of psychological dread.

-   **Dynamic Sanity Meter:** The player's sanity level changes based on in-game events, such as encountering horrific creatures, witnessing disturbing events, or using specific items.
-   **Perceptual Distortions:** As sanity drops, the player will experience a range of effects, including:
    -   **Visual Distortions:** Screen effects like chromatic aberration, film grain, and stretching visuals.
    -   **Audio Hallucinations:** False sound cues, whispers, and distorted music.
    -   **False Enemies:** Illusions of enemies may appear and disappear, designed to keep the player on edge.
-   **EventBus Integration:** The Sanity system is integrated via the global `EventBus`, allowing it to trigger and be triggered by other game systems in a modular way.

---

## 4. Methodical Soulslike Combat

The combat is designed to be slow, deliberate, and punishing, drawing inspiration from the Soulslike genre. It emphasizes careful timing, strategic positioning, and stamina management over fast reflexes. The control scheme is being meticulously designed to deliver this weighty feel on touchscreens.

   **Core Mechanics:**
    -   **Stamina-Based Actions:** All major actions—attacking, dodging, blocking—consume stamina, requiring the player to manage their exertion carefully.
    -   **Heavy & Committed Attacks:** Attack animations are deliberate and have significant recovery frames, making each swing a calculated risk. There are no long, cancelable combos.
    -   **Dodge Rolling:** The primary defensive maneuver with i-frames, but its use is limited by the stamina bar.
    -   **Parrying/Guarding:** A high-risk, high-reward defensive option will be explored.

   **Status Effects:** Players and enemies can be affected by a variety of impactful status effects, including:
    -   `Bleed`: Causes a burst of high damage once the threshold is met.
    -   `Corruption`: Reduces healing effectiveness.
    -   `Madness`: Drains sanity.
    -   `Poison`: Damage over time, ignores armor.
    -   `Curse`: Increases damage taken.

   **Mobile-First Design:** The system is balanced around the deliberate nature of touch input, avoiding the need for rapid, complex button combinations. The focus is on timing and strategy, which translates well to a mobile interface.

---

## 5. Mutation & Progression System

The Mutation system offers permanent character evolution, allowing players to tailor their build across multiple runs.

-   **Permanent Evolution:** Mutations are permanent upgrades that provide significant visual and mechanical changes to the player character.
-   **Synergistic Choices:** Players are limited to a small number of mutations per run (e.g., 3), encouraging thoughtful choices and creating powerful synergies between different abilities.
-   **Examples:** A mutation might grant lifesteal on attacks, add a poison effect to dodge rolls, or allow the player to see hidden passages.

---

## 6. Blood Echoes Economy

Blood Echoes are the primary currency, with a unique risk-reward system integrated into the economy.

-   **Primary Currency:** Gained from defeating enemies and used for purchasing items, upgrading gear, and interacting with certain NPCs.
-   **Standard Shops:** Found periodically (e.g., every two dungeons) offering standard goods.
-   **The Black Market:** A special vendor that offers powerful and unique items but at a cost to the player's **Sanity** instead of their Blood Echoes, presenting a difficult choice between power and stability. 