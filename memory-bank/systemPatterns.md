# System Patterns: Depths of the Bastard God

## Architecture Overview

### Core Pattern: Hybrid Event-Driven Architecture with Reality Distortion
The game uses a centralized event system (`EventBus`) to decouple systems and enable flexible communication between components, **with hybrid procedural generation and sanity-based reality manipulation**.

```
EventBus (Autoload)
├── GameManager (Autoload) - Global state, act management, hybrid coordination
├── PlayerStats (Autoload) - Player data, mutations
├── SanityManager (Autoload) - Reality distortion controller
├── UICorruption (Autoload) - Interface manipulation system
├── SaveCorruption (Autoload) - False save management
├── HybridGenerator (Autoload) - Coordinates handcrafted + procedural systems
├── TagSystem (Autoload) - Manages tag combinations and validation
├── TemplateManager (Autoload) - Modular room template system
├── SafetyChecker (Autoload) - Failsafe validation system
├── Player Scene - Character controller
├── World Generator - Hybrid world creation
├── UI System - Sanity-responsive interface
└── Save System - Corruption-aware persistence
```

### Hybrid Generation Architecture

#### **Handcrafted Foundation Layer**
```
HandcraftedManager (Autoload)
├── ActStructure - Three-act progression framework
├── KeyEvents - Scripted narrative moments
├── BossEncounters - Core boss mechanics
├── RoomLayouts - Base room flow and structure
├── ProgressionSystems - Balanced advancement paths
└── UICorruptionPatterns - Designed lies and distortions
```

#### **Procedural Enhancement Layer**
```
ProceduralManager (Autoload)
├── TagSystem - Enemy/item combination engine
├── TemplateSystem - Modular room generation
├── VariantGenerator - Enemy/item modifications
├── LoreSelector - Semi-procedural narrative
├── EnvironmentDetails - Atmospheric generation
└── SanityVariations - Corruption of handcrafted elements
```

#### **Safety and Quality Layer**
```
SafetyManager (Autoload)
├── SoftlockChecker - Progression validation
├── PerformanceMonitor - Mobile optimization
├── NarrativeValidator - Thematic coherence
├── TagValidator - Combination sensibility
├── GenerationLogger - Debug and monitoring
└── QualityMetrics - Player engagement tracking
```

## Hybrid Generation Patterns

### Tag System Architecture

#### **Tag Categories and Inheritance**
```gdscript
# Base tag system with inheritance
class_name TagSystem extends Node

enum TagCategory {
    BASE,        # [humanoid], [beast], [construct], [spirit], [amalgam]
    BEHAVIOR,    # [fast], [slow], [aggressive], [defensive], [chaotic]
    CORRUPTION,  # [deformed], [burning], [bleeding], [mad], [false]
    ELEMENT,     # [fire], [water], [shadow], [light], [void]
    SANITY,      # [real], [hallucination], [disguised], [lying]
    QUALITY,     # [crude], [fine], [masterwork], [cursed], [blessed]
    EFFECT,      # [sharp], [heavy], [light], [poisoned], [burning]
    MUTATION     # [organic], [mechanical], [ethereal], [corrupted]
}

# Tag combination validation
func validate_combination(tags: Array[String]) -> bool:
    return SafetyChecker.check_tag_combination(tags)

# Generate entity from tag combination
func create_from_tags(tags: Array[String]) -> Entity:
    var base_template = HandcraftedManager.get_base_template(tags[0])
    var procedural_mods = ProceduralManager.apply_tags(base_template, tags)
    return SafetyChecker.validate_entity(procedural_mods)
```

#### **Tag Combination Rules**
```gdscript
# Tag combination validation rules
class_name TagValidator extends Node

# Forbidden combinations that break game logic
const FORBIDDEN_COMBINATIONS = [
    ["fast", "slow"],           # Contradictory behavior
    ["real", "hallucination"],  # Contradictory existence
    ["blessed", "cursed"],      # Contradictory quality
    ["fire", "water"]           # Contradictory elements (unless special)
]

# Required combinations for certain tags
const REQUIRED_COMBINATIONS = {
    "false": ["hallucination", "lying"],  # False things must be unreal
    "disguised": ["real"],                # Only real things can disguise
    "masterwork": ["fine"]                # Masterwork implies fine quality
}

# Maximum tags per entity (mobile performance)
const MAX_TAGS_PER_ENTITY = 6

func validate_tags(tags: Array[String]) -> ValidationResult:
    # Check forbidden combinations
    # Verify required combinations
    # Ensure mobile performance limits
    # Return validation result with suggestions
```

### Modular Template System

#### **Template Categories and Structure**
```gdscript
# Room template system with mobile optimization
class_name TemplateManager extends Node

enum TemplateType {
    FUNCTIONAL,    # "altar room", "shop chamber", "save shrine"
    ATMOSPHERIC,   # "flooded corridor", "collapsed ceiling"
    MECHANICAL,    # "puzzle chamber", "trap gauntlet"
    NARRATIVE,     # "lore library", "memory fragment"
    CORRUPTION     # "impossible geometry", "lying walls"
}

# Template structure for mobile memory efficiency
class RoomTemplate:
    var id: String
    var type: TemplateType
    var act_variants: Dictionary  # Different versions per act
    var required_connections: Array[String]
    var optional_features: Array[String]
    var mobile_optimized: bool = true
    var generation_time_limit: float = 1.0  # Max generation time

# Template instantiation with safety checks
func instantiate_template(template_id: String, act: int) -> Room:
    var template = get_template(template_id)
    var room = HandcraftedManager.create_base_room(template, act)
    room = ProceduralManager.add_details(room, template)
    return SafetyChecker.validate_room(room)
```

#### **Template Variation System**
```gdscript
# Act-specific template variations
class_name TemplateVariations extends Node

# Act I: Urban templates with architectural horror
const ACT_1_TEMPLATES = {
    "apartment_room": {
        "base": "residential_space",
        "corruption": ["twisted_walls", "impossible_doors"],
        "atmosphere": ["urban_decay", "domestic_horror"]
    },
    "office_corridor": {
        "base": "commercial_hallway",
        "corruption": ["fluorescent_flicker", "endless_cubicles"],
        "atmosphere": ["corporate_dread", "maze_logic"]
    }
}

# Act II: Organic templates with water hazards
const ACT_2_TEMPLATES = {
    "flooded_chamber": {
        "base": "underground_room",
        "corruption": ["living_water", "breathing_walls"],
        "atmosphere": ["drowning_fear", "organic_growth"]
    },
    "flesh_corridor": {
        "base": "tunnel_passage",
        "corruption": ["pulsing_walls", "digestive_tract"],
        "atmosphere": ["body_horror", "claustrophobia"]
    }
}

# Act III: Impossible templates with reality distortion
const ACT_3_TEMPLATES = {
    "paradox_room": {
        "base": "geometric_space",
        "corruption": ["non_euclidean", "recursive_loops"],
        "atmosphere": ["dream_logic", "reality_breakdown"]
    }
}
```

### Safety and Quality Assurance Patterns

#### **Failsafe Checker System**
```gdscript
# Comprehensive safety checking for hybrid generation
class_name SafetyChecker extends Node

# Softlock prevention
func check_progression_validity(room: Room) -> bool:
    # Ensure every room has valid exit paths
    # Verify required items/abilities are obtainable
    # Check for impossible navigation scenarios
    return validate_room_connectivity(room)

# Performance monitoring for mobile
func check_mobile_performance(generation_data: Dictionary) -> bool:
    var generation_time = generation_data.get("time", 0.0)
    var memory_usage = generation_data.get("memory", 0)
    var complexity_score = generation_data.get("complexity", 0)
    
    return (generation_time < 2.0 and 
            memory_usage < MOBILE_MEMORY_LIMIT and
            complexity_score < MOBILE_COMPLEXITY_LIMIT)

# Narrative coherence validation
func check_narrative_coherence(lore_selection: Array[String], context: Dictionary) -> bool:
    # Validate lore selections make thematic sense
    # Check for contradictory narrative elements
    # Ensure act-appropriate content
    return validate_thematic_consistency(lore_selection, context)

# Tag combination sensibility
func validate_tag_combination(tags: Array[String]) -> ValidationResult:
    var result = ValidationResult.new()
    
    # Check for forbidden combinations
    for forbidden in TagValidator.FORBIDDEN_COMBINATIONS:
        if tags.has_all(forbidden):
            result.add_error("Forbidden combination: " + str(forbidden))
    
    # Verify required combinations
    for tag in tags:
        if TagValidator.REQUIRED_COMBINATIONS.has(tag):
            var required = TagValidator.REQUIRED_COMBINATIONS[tag]
            if not tags.has_any(required):
                result.add_error("Missing required tags for " + tag)
    
    # Check mobile performance limits
    if tags.size() > TagValidator.MAX_TAGS_PER_ENTITY:
        result.add_warning("Too many tags for mobile performance")
    
    return result
```

#### **Debug and Monitoring System**
```gdscript
# Comprehensive logging and monitoring for hybrid systems
class_name GenerationLogger extends Node

# Generation event logging
func log_generation_event(event_type: String, data: Dictionary):
    var log_entry = {
        "timestamp": Time.get_unix_time_from_system(),
        "type": event_type,
        "data": data,
        "performance": get_performance_metrics()
    }
    
    # Special logging for problematic generations
    if event_type == "ERROR":
        log_entry["debug_info"] = get_debug_context()
        print("GENERATION ERROR: ", data.get("message", "Unknown error"))
        print("Context: ", log_entry["debug_info"])
    
    generation_log.append(log_entry)

# Performance profiling
func profile_generation(generator_func: Callable, params: Dictionary) -> Dictionary:
    var start_time = Time.get_ticks_msec()
    var start_memory = OS.get_static_memory_usage_by_type()
    
    var result = generator_func.call(params)
    
    var end_time = Time.get_ticks_msec()
    var end_memory = OS.get_static_memory_usage_by_type()
    
    return {
        "result": result,
        "generation_time": (end_time - start_time) / 1000.0,
        "memory_delta": end_memory - start_memory,
        "performance_rating": calculate_performance_rating(end_time - start_time)
    }

# Quality metrics tracking
func track_player_engagement(content_type: String, engagement_data: Dictionary):
    # Track how players interact with procedural content
    # Monitor which tag combinations are most engaging
    # Identify template patterns that work well
    # Log sanity corruption effectiveness
    quality_metrics[content_type].append(engagement_data)
```

## Sanity System Integration Patterns

### Reality Distortion Architecture
```gdscript
# Sanity-based reality manipulation system
class_name SanityManager extends Node

# Sanity level thresholds
enum SanityLevel {
    HIGH,    # 75-100%: Stable reality
    MEDIUM,  # 50-74%: Minor distortions
    LOW,     # 25-49%: Major corruption
    ZERO     # 0-24%: Complete breakdown
}

# Coordinate reality distortion across hybrid systems
func apply_sanity_effects(current_sanity: float):
    var level = get_sanity_level(current_sanity)
    
    # Affect handcrafted elements
    HandcraftedManager.apply_sanity_corruption(level)
    
    # Modify procedural generation
    ProceduralManager.set_sanity_influence(level)
    
    # Corrupt UI systems
    UICorruption.set_corruption_level(level)
    
    # Manipulate save system
    SaveCorruption.set_lie_probability(level)
    
    # Emit events for other systems
    EventBus.emit_signal("sanity_changed", current_sanity, level)
```

### UI Corruption Patterns
```gdscript
# UI corruption system that lies to players
class_name UICorruption extends Node

# Corruption effects by sanity level
func apply_ui_corruption(sanity_level: SanityManager.SanityLevel):
    match sanity_level:
        SanityManager.SanityLevel.HIGH:
            # No corruption - UI works normally
            reset_all_corruption()
        
        SanityManager.SanityLevel.MEDIUM:
            # Minor lies - health bars flicker, item descriptions occasionally wrong
            apply_minor_corruption()
        
        SanityManager.SanityLevel.LOW:
            # Major lies - UI actively misleads player
            apply_major_corruption()
        
        SanityManager.SanityLevel.ZERO:
            # Complete breakdown - UI becomes unreliable
            apply_complete_corruption()

# Specific corruption implementations
func corrupt_health_display():
    # Show wrong health values
    # Make health bars lie about current state
    # Display false damage/healing numbers

func corrupt_item_descriptions():
    # Randomize item text
    # Show false properties
    # Make items claim to do things they don't

func corrupt_map_display():
    # Show false room layouts
    # Hide real exits
    # Display fake passages
```

## Mobile Optimization Patterns

### Performance-First Hybrid Generation
```gdscript
# Mobile-optimized generation with quality preservation
class_name MobileOptimizer extends Node

# Generation time limits for mobile
const MOBILE_GENERATION_LIMITS = {
    "room_template": 1.0,      # 1 second max
    "enemy_variant": 0.5,      # 0.5 seconds max
    "item_combination": 0.3,   # 0.3 seconds max
    "lore_selection": 0.2      # 0.2 seconds max
}

# Memory usage limits
const MOBILE_MEMORY_LIMITS = {
    "active_rooms": 5,         # Max rooms in memory
    "enemy_variants": 20,      # Max enemy types loaded
    "item_combinations": 50,   # Max item variants
    "template_cache": 10       # Max cached templates
}

# Optimize generation for mobile constraints
func optimize_for_mobile(generation_request: Dictionary) -> Dictionary:
    # Reduce complexity if needed
    # Cache frequently used combinations
    # Preload common templates
    # Limit concurrent generation processes
    return apply_mobile_constraints(generation_request)
```

### Memory Management for Hybrid Systems
```gdscript
# Efficient memory management for procedural content
class_name HybridMemoryManager extends Node

# Object pooling for frequently generated content
var enemy_pool: Array[Enemy] = []
var item_pool: Array[Item] = []
var room_detail_pool: Array[RoomDetail] = []

# Cache management for templates and tag combinations
var template_cache: Dictionary = {}
var tag_combination_cache: Dictionary = {}

# Memory cleanup for mobile
func cleanup_unused_content():
    # Remove old procedural content
    # Clear unused template variations
    # Reset object pools
    # Garbage collect safely
    
# Preload common combinations for performance
func preload_common_combinations():
    # Load frequently used tag combinations
    # Cache popular template variations
    # Prepare common enemy/item variants
```

## Event-Driven Communication Patterns

### Hybrid System Coordination
```gdscript
# EventBus signals for hybrid system coordination
extends Node

# Hybrid generation events
signal handcrafted_element_loaded(element_type: String, element_data: Dictionary)
signal procedural_generation_requested(request_type: String, parameters: Dictionary)
signal template_instantiated(template_id: String, room_data: Dictionary)
signal tag_combination_applied(entity: Node, tags: Array[String])

# Safety and quality events
signal generation_error(error_type: String, context: Dictionary)
signal performance_warning(system: String, metrics: Dictionary)
signal quality_check_failed(content_type: String, issues: Array[String])
signal safety_check_passed(validation_type: String, content: Dictionary)

# Sanity system events
signal sanity_corruption_applied(corruption_type: String, target: Node)
signal reality_distortion_triggered(distortion_level: int, affected_systems: Array[String])
signal ui_corruption_activated(corruption_effects: Array[String])
signal save_corruption_detected(corruption_type: String, save_data: Dictionary)
```

## Data Persistence Patterns

### Hybrid Content Serialization
```gdscript
# Serialization for hybrid procedural content
class_name HybridSerializer extends Node

# Serialize procedural content efficiently
func serialize_procedural_content(content: Dictionary) -> Dictionary:
    return {
        "handcrafted_base": content.get("base_template", ""),
        "applied_tags": content.get("tags", []),
        "procedural_seed": content.get("seed", 0),
        "generation_timestamp": Time.get_unix_time_from_system(),
        "quality_validated": content.get("validated", false)
    }

# Deserialize with safety validation
func deserialize_procedural_content(data: Dictionary) -> Dictionary:
    var content = reconstruct_from_data(data)
    return SafetyChecker.validate_deserialized_content(content)
```

This hybrid architecture ensures that the game maintains handcrafted quality while providing infinite procedural variety, all optimized for mobile performance with comprehensive safety systems. 