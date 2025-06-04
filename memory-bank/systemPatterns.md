# System Patterns: Depths of the Bastard God

## Architecture Overview

### Core Pattern: Event-Driven Architecture
The game uses a centralized event system (`EventBus`) to decouple systems and enable flexible communication between components.

```
EventBus (Autoload)
├── GameManager (Autoload) - Global state
├── PlayerStats (Autoload) - Player data
├── Player Scene - Character controller
├── World Generator - Procedural systems
├── UI Systems - Interface management
└── Audio Manager - Dynamic sound
```

### Autoload System Pattern
Three core autoloads manage global state:

1. **GameManager**: Game state, currency, sanity, progression
2. **PlayerStats**: Character stats, equipment, mutations, class data
3. **EventBus**: Communication hub for all systems

### Scene Organization Pattern
```
scenes/
├── main/           # Main game scene
├── player/         # Player character and components
├── enemies/        # Enemy types and AI
├── world/          # Room templates and generation
├── ui/             # Interface elements
└── effects/        # Visual and audio effects
```

## Key Design Patterns

### 1. Component System
Each game entity uses composition over inheritance:

```gdscript
# Example: Player composed of multiple components
Player
├── MovementComponent
├── CombatComponent
├── HealthComponent
├── SanityComponent
└── InventoryComponent
```

### 2. State Machine Pattern
Used for complex behaviors (player states, enemy AI, game flow):

```gdscript
# Player states
PlayerStateMachine
├── IdleState
├── MovingState
├── AttackingState
├── DodgingState
└── DeadState
```

### 3. Observer Pattern (via EventBus)
Systems communicate through events rather than direct references:

```gdscript
# Example: Sanity change affects multiple systems
EventBus.sanity_changed.emit(new_value)
# Listened to by: UI, Audio, Visual Effects, Enemy AI
```

### 4. Factory Pattern
For procedural generation of entities:

```gdscript
# Factories create configured entities
EnemyFactory.create_enemy(type, level, mutations)
WeaponFactory.create_weapon(base_type, modifiers)
RoomFactory.create_room(theme, difficulty, size)
```

### 5. Strategy Pattern
For different behaviors based on context:

```gdscript
# Different AI strategies
EnemyAI
├── AggressiveStrategy
├── DefensiveStrategy
├── SupportStrategy
└── ChaosStrategy
```

## System Interactions

### Core Game Loop
```
1. Input Processing → Player Controller
2. Player Actions → EventBus → Affected Systems
3. World Update → Physics, AI, Generation
4. Sanity Processing → Reality Distortion
5. Render Pipeline → Visual Effects
6. Audio Processing → Dynamic Music/SFX
```

### Procedural Generation Pipeline
```
Generation Request
├── Theme Selection (based on Act/Sanity)
├── Base Generation (layout, structure)
├── Asset Generation (textures, sounds)
├── Entity Placement (enemies, items)
├── Narrative Integration (lore, story)
└── Optimization (LOD, culling)
```

### Save System Architecture
```
SaveData
├── PlayerProgress (stats, equipment, mutations)
├── WorldState (current dungeon, discovered areas)
├── GenerationSeeds (reproduce procedural content)
├── NarrativeState (story progress, choices)
└── Settings (preferences, accessibility)
```

## Performance Patterns

### 1. Object Pooling
Reuse expensive objects to avoid garbage collection:
- Projectiles
- Particle effects
- Audio sources
- UI elements

### 2. Lazy Loading
Generate content only when needed:
- Room details when entering
- Audio when triggered
- Textures when visible

### 3. Level-of-Detail (LOD)
Reduce complexity based on distance/importance:
- Simplified enemy AI when off-screen
- Lower resolution textures for distant objects
- Reduced particle density

### 4. Streaming
Load/unload content dynamically:
- Room streaming as player moves
- Audio streaming for music
- Texture streaming for variety

## Data Management Patterns

### 1. Resource Management
```gdscript
# Centralized resource handling
ResourceManager
├── TextureCache (generated textures)
├── AudioCache (generated sounds)
├── MeshCache (procedural geometry)
└── DataCache (enemy stats, item data)
```

### 2. Configuration System
```gdscript
# Data-driven configuration
GameConfig
├── PlayerClasses.json
├── EnemyTypes.json
├── ItemDatabase.json
├── GenerationRules.json
└── BalanceData.json
```

### 3. Serialization Pattern
Consistent save/load across all systems:
```gdscript
# All saveable objects implement
class_name Saveable
func serialize() -> Dictionary
func deserialize(data: Dictionary) -> void
```

## Error Handling Patterns

### 1. Graceful Degradation
When procedural generation fails:
- Fall back to simpler generation
- Use cached content
- Provide default assets
- Log for debugging

### 2. Validation System
Ensure generated content meets requirements:
- Playable room layouts
- Balanced enemy encounters
- Coherent visual themes
- Performance constraints

### 3. Recovery Mechanisms
Handle runtime errors:
- Auto-save before risky operations
- Rollback failed generations
- Alternative content paths
- User notification system

## Testing Patterns

### 1. Procedural Testing
- Seed-based reproducible tests
- Statistical validation of generation
- Performance benchmarking
- Edge case detection

### 2. Component Testing
- Isolated system testing
- Mock dependencies
- Event simulation
- State validation

### 3. Integration Testing
- Full gameplay loops
- Cross-system communication
- Save/load validation
- Performance profiling

## Debugging Patterns

### 1. Debug Visualization
- Generation process visualization
- AI state display
- Performance metrics overlay
- Event flow tracking

### 2. Logging System
```gdscript
# Structured logging
Logger
├── GenerationLogs (procedural details)
├── PerformanceLogs (timing, memory)
├── ErrorLogs (failures, exceptions)
└── PlayerLogs (actions, progression)
```

### 3. Development Tools
- In-game console
- Parameter tweaking
- Real-time profiling
- Content inspection

## Scalability Patterns

### 1. Modular Systems
Each system can be developed/tested independently:
- Clear interfaces
- Minimal dependencies
- Configurable behavior
- Hot-swappable components

### 2. Data-Driven Design
Game behavior controlled by external data:
- Easy balancing
- Content iteration
- Mod support potential
- Designer-friendly tools

### 3. Performance Scaling
Adapt to different hardware:
- Quality settings
- Feature toggles
- Dynamic LOD
- Adaptive generation complexity 