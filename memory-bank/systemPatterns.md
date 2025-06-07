# System Patterns: Depths of the Bastard God

## 🚨 CRITICAL MAINTENANCE RULE 🚨
**ALWAYS UPDATE THIS FILE WHEN CREATING, MOVING, OR DELETING ANY PROJECT FILES**
This file serves as the central architecture documentation and MUST be kept current with all file locations, system patterns, and architectural decisions. Update the **File Locations** section immediately after any file system changes.

## 🧪 CRITICAL TESTING RULE 🧪
**ALWAYS TEST FIRST BEFORE MARKING TASKS COMPLETE**
Every implementation must be tested and validated before being marked as done. Run test suites, validate functionality, and ensure mobile performance meets requirements. No task is complete without successful testing.

## 📁 Complete Project File Locations

### Core Autoload Scripts
- `dotbg/scripts/autoload/game_manager.gd` - Global game state and act management
- `dotbg/scripts/autoload/player_stats.gd` - Player data and progression
- `dotbg/scripts/autoload/event_bus.gd` - Central event system
- `dotbg/scripts/autoload/save_system.gd` - Save/load functionality
- `dotbg/scripts/autoload/input_manager.gd` - Epic touch input system
- `dotbg/scripts/autoload/sanity_manager.gd` - Reality distortion controller
- `dotbg/scripts/autoload/hybrid_generator.gd` - Procedural generation coordinator

### UI Systems
- `dotbg/scripts/ui/touch_settings_ui.gd` - Touch configuration interface
- `dotbg/scripts/ui/touch_controls.gd` - Touch control components
- `dotbg/scripts/ui/virtual_joystick.gd` - Virtual joystick implementation
- `dotbg/scripts/ui/main_menu.gd` - Main menu interface

### Debug Tools
- `dotbg/scripts/debug/input_debug_overlay.gd` - Visual debug overlay
- `dotbg/scripts/debug/input_debug_console.gd` - Command-line debug console
- `dotbg/scenes/debug/DebugTools.tscn` - Combined debug scene

### Test Suite
- `dotbg/scripts/tests/debug_tools_test.gd` - Comprehensive debug test suite
- `dotbg/scripts/tests/touch_test.gd` - Touch input testing
- `dotbg/scripts/tests/input_debounce_test.gd` - Input debounce testing
- `dotbg/scripts/tests/haptic_feedback_test.gd` - Haptic feedback testing

### Hybrid Generation System
- `dotbg/scripts/systems/handcrafted_manager.gd` - Manages the handcrafted, persistent world structure and key events.
- `dotbg/scripts/systems/procedural_manager.gd` - Manages the procedural generation of dungeon layouts and enemy encounters within the handcrafted world.
- `dotbg/scripts/systems/safety_checker.gd` - Quality assurance and validation for generated content.
- `dotbg/scripts/systems/tag_system.gd` - Engine for combining entity tags to create variations.
- `dotbg/scripts/systems/template_system.gd` - Manages modular room templates for procedural generation.
- `dotbg/scripts/procedural/AssetGenerator.gd` - Generates visual and audio asset variations.
- `dotbg/scripts/procedural/CreatureGenerator.gd` - Generates variations of procedural enemies.

### Core Game Systems
- `dotbg/scripts/characters/player/player.gd` - Player character controller

### Project Configuration
- `dotbg/project.godot` - Godot project configuration
- `dotbg/export_presets.cfg` - Export settings for mobile deployment

### Memory Bank Documentation
- `memory-bank/projectbrief.md` - Core project requirements
- `memory-bank/productContext.md` - Product vision and goals
- `memory-bank/activeContext.md` - Current development focus
- `memory-bank/systemPatterns.md` - Architecture documentation (THIS FILE)
- `memory-bank/techContext.md` - Technical specifications
- `memory-bank/progress.md` - Development progress tracking


### TaskMaster Integration
- `.taskmaster/tasks/tasks.json` - Task management data
- `.taskmaster/config.json` - TaskMaster configuration

**🚨 REMEMBER: Update this section immediately when creating, moving, or deleting ANY project files! 🚨**

## Architecture Overview

### Core Pattern: Hybrid Event-Driven Architecture with Reality Distortion
The game uses a centralized event system (`EventBus`) to decouple systems. A `HybridGenerator` coordinates between the `HandcraftedManager` (for the persistent world) and the `ProceduralManager` (for dungeons/enemies) to create a seamless, blended world.

```
EventBus (Autoload)
├── GameManager (Autoload) - Global state, act management
├── PlayerStats (Autoload) - Player data, mutations
├── SanityManager (Autoload) - Reality distortion controller
├── HybridGenerator (Autoload) - Coordinates handcrafted + procedural systems
│   ├── HandcraftedManager - Manages persistent world, quests, key events
│   └── ProceduralManager - Generates dungeons, enemies, loot
├── Player Scene - Character controller
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

## Event Propagation System

### Event Propagation Architecture
```gdscript
# Event propagation system with mobile optimization
class_name EventPropagationSystem extends Node

enum EventLayer {
    UI,      # Highest priority - interface elements
    GAME,    # Medium priority - game objects
    WORLD    # Lowest priority - environment
}

# Layer-based event targeting
var ui_nodes: Array[Node] = []
var game_nodes: Array[Node] = []
var world_nodes: Array[Node] = []

# Event statistics for epic systems
var events_propagated: int = 0
var events_handled: int = 0
var average_handling_time: float = 0.0

func register_ui_node(node: Node) -> void:
    if not ui_nodes.has(node):
        ui_nodes.append(node)

func register_game_node(node: Node) -> void:
    if not game_nodes.has(node):
        game_nodes.append(node)

func register_world_node(node: Node) -> void:
    if not world_nodes.has(node):
        world_nodes.append(node)

func unregister_node(node: Node) -> void:
    ui_nodes.erase(node)
    game_nodes.erase(node)
    world_nodes.erase(node)

# Propagate touch events through layers with epic performance
func propagate_touch_event(event_type: String, event_data: Dictionary) -> bool:
    var start_time = Time.get_time_dict_from_system()
    events_propagated += 1
    
    # Try UI layer first (highest priority)
    for node in ui_nodes:
        if node.has_method("handle_touch_event"):
            if node.handle_touch_event(event_type, event_data):
                events_handled += 1
                _update_performance_stats(start_time)
                return true
    
    # Try game layer (medium priority)
    for node in game_nodes:
        if node.has_method("handle_touch_event"):
            if node.handle_touch_event(event_type, event_data):
                events_handled += 1
                _update_performance_stats(start_time)
                return true
    
    # Try world layer (lowest priority)
    for node in world_nodes:
        if node.has_method("handle_touch_event"):
            if node.handle_touch_event(event_type, event_data):
                events_handled += 1
                _update_performance_stats(start_time)
                return true
    
    _update_performance_stats(start_time)
    return false

func _update_performance_stats(start_time: Dictionary) -> void:
    var end_time = Time.get_time_dict_from_system()
    var handling_time = (end_time.second - start_time.second) * 1000.0
    average_handling_time = (average_handling_time + handling_time) / 2.0

func get_propagation_stats() -> Dictionary:
    return {
        "events_propagated": events_propagated,
        "events_handled": events_handled,
        "average_handling_time_ms": average_handling_time,
        "registered_nodes": {
            "ui": ui_nodes.size(),
            "game": game_nodes.size(),
            "world": world_nodes.size()
        }
    }
```

### Touch Input Integration Pattern

#### **InputManager Integration with Event Propagation**
```gdscript
# InputManager.gd - Epic touch input with event propagation
extends Node

var event_propagation: EventPropagationSystem

func _ready() -> void:
    event_propagation = EventPropagationSystem.new()
    add_child(event_propagation)

func _on_gesture_recognized(gesture_type: String, gesture_data: Dictionary) -> void:
    # Emit legacy signal for backwards compatibility
    gesture_detected.emit(gesture_type, gesture_data)
    
    # Use event propagation system for modern event handling
    var handled = event_propagation.propagate_touch_event(gesture_type, gesture_data)
    
    # Buffer combat actions if not handled by specific targets
    if not handled and gesture_type in ["tap", "swipe", "hold"]:
        input_buffer.buffer_action(gesture_type, gesture_data)
    
    # Trigger haptic feedback for epic mobile experience
    if haptic_controller:
        haptic_controller.trigger_gesture_feedback(gesture_type, gesture_data)

# Public API for event registration
func register_ui_event_target(node: Node) -> void:
    if event_propagation:
        event_propagation.register_ui_node(node)

func register_game_event_target(node: Node) -> void:
    if event_propagation:
        event_propagation.register_game_node(node)

func register_world_event_target(node: Node) -> void:
    if event_propagation:
        event_propagation.register_world_node(node)

func unregister_event_target(node: Node) -> void:
    if event_propagation:
        event_propagation.unregister_node(node)

func get_event_propagation_stats() -> Dictionary:
    if event_propagation:
        return event_propagation.get_propagation_stats()
    return {}
```

### TouchSettingsUI Integration Pattern

#### **Fixed TouchSettingsUI for Scene Structure Compatibility**
```gdscript
# TouchSettingsUI.gd - Fixed for actual scene structure
extends Control

# UI Node references - using safe get_node calls to prevent crashes
var main_container: VBoxContainer
var touch_sensitivity_slider: HSlider
var touch_sensitivity_label: Label
var gesture_threshold_slider: HSlider
var gesture_threshold_label: Label

# Haptic controls
var haptic_enabled_toggle: CheckBox
var haptic_intensity_slider: HSlider
var haptic_intensity_label: Label

# Buttons
var reset_button: Button
var save_button: Button
var back_button: Button

signal settings_changed
signal back_pressed

func _ready() -> void:
    if not InputManager:
        push_error("InputManager not found - TouchSettingsUI cannot function")
        return
    
    _setup_ui_references()
    _connect_signals()
    _load_current_settings()

func _setup_ui_references() -> void:
    # Safe node references that handle missing nodes gracefully
    main_container = get_node_or_null("MainContainer")
    
    # Sensitivity controls
    touch_sensitivity_slider = get_node_or_null("MainContainer/TouchSensitivity/HSlider")
    touch_sensitivity_label = get_node_or_null("MainContainer/TouchSensitivity/Label")
    
    # Only setup controls if nodes exist
    if touch_sensitivity_slider:
        touch_sensitivity_slider.min_value = 0.1
        touch_sensitivity_slider.max_value = 3.0
        touch_sensitivity_slider.step = 0.1
        touch_sensitivity_slider.value = InputManager.touch_sensitivity
    
    # Additional safe setup for other controls...

func _connect_signals() -> void:
    # Connect signals only if sliders exist
    if touch_sensitivity_slider:
        touch_sensitivity_slider.value_changed.connect(_on_touch_sensitivity_changed)
    
    # Connect other signals safely...

func _on_touch_sensitivity_changed(value: float) -> void:
    InputManager.touch_sensitivity = value
    if touch_sensitivity_label:
        touch_sensitivity_label.text = "%.1f" % value
    settings_changed.emit()
```

This hybrid architecture ensures that the game maintains handcrafted quality while providing infinite procedural variety, all optimized for mobile performance with comprehensive safety systems. 