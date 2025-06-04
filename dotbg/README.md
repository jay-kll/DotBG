# Depths of the Bastard God

A Lovecraftian roguelike mobile game built with Godot 4.4.1, featuring cosmic horror elements and challenging gameplay.

## Project Status

### Completed Features

#### Core Systems
- GameManager for global state management
- PlayerStats system with detailed progression
- EventBus for game-wide communication
- SaveSystem for save/load functionality
- Basic main menu scene

#### Player Character
- State machine-based character controller
- Smooth movement mechanics with acceleration
- Double jump with coyote time
- Combat system with combo attacks
- Dodge roll with invincibility frames
- Stamina management
- Mobile-optimized touch controls

#### Mobile Optimization
- Landscape-only orientation
- Touch controls with virtual joystick
- Action buttons for jump, attack, and dodge
- Mobile-friendly rendering settings
- VRAM compression for better performance
- MSAA for smoother graphics
- Touch input with proper multi-touch support

### Current Implementation Details

#### Touch Controls Layout
- Left side: Virtual joystick for movement
  - Semi-transparent design
  - Dynamic thumb position
  - Smooth input handling
- Right side: Action buttons
  - Jump button (top)
  - Attack button (bottom right)
  - Dodge button (bottom left)
  - Optimized button placement for thumb reach

#### Character Classes
- Cultist: High sanity resistance, better stamina management
- Warrior: High health and defense, slower movement
- Scholar: Item identification, quick recovery

#### Progression System
- Level cap: 50
- Experience scaling: 15% increase per level
- Major gameplay improvements at levels 10, 20, and 30
- Class-specific attribute scaling
- Detailed stat tracking

### Roadmap

#### Next Steps
1. Player Visual Assets
   - Character sprites for all classes
   - Animation sets for all states
   - Visual effects for abilities

2. Combat System Enhancement
   - Weapon implementation
   - Class-specific abilities
   - Enemy AI and patterns
   - Combat visual feedback

3. Level Generation
   - Procedural dungeon generation
   - Room templates and variations
   - Environmental hazards
   - Secret areas

4. UI/UX Implementation
   - Health and stamina bars
   - Combo counter
   - Minimap
   - Inventory system
   - Equipment management

5. Mobile Features
   - Touch control customization
   - Performance optimization
   - Screen size adaptation
   - Mobile-specific UI scaling

6. Content Creation
   - 15 unique dungeons
   - Boss encounters
   - Item variety
   - Story elements

7. Polish
   - Sound effects
   - Music
   - Particle effects
   - Screen shake and juice
   - Loading screens
   - Tutorial system

## Technical Requirements
- Godot 4.4.1
- Mobile device with Android/iOS
- Minimum resolution: 1280x720
- Landscape orientation only

## Development Setup
1. Clone the repository
2. Open the project in Godot 4.4.1
3. Install Android/iOS export templates
4. Configure mobile export settings
5. Run the project

## Controls
- Virtual joystick (left side): Movement
- Jump button (top right): Jump/Double jump
- Attack button (bottom right): Combat
- Dodge button (bottom left): Dodge roll with i-frames

## Notes
- The game is designed exclusively for landscape orientation
- Touch controls are optimized for one-handed play
- UI elements are positioned for minimal thumb movement
- All visual elements use pixel art style for consistent aesthetic 