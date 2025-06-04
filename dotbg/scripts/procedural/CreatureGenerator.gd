extends Node

class_name CreatureGenerator

# Creature parts and attributes
var body_types := ["amorphous", "humanoid", "insectoid", "tentacled"]
var feature_types := ["eyes", "mouths", "tentacles", "spikes", "growths"]
var behavior_patterns := ["aggressive", "stalking", "territorial", "erratic"]

# Noise for consistency in generation
var noise := FastNoiseLite.new()
var rng := RandomNumberGenerator.new()

func _init():
    noise.seed = randi()
    rng.seed = noise.seed

class CreatureDefinition:
    var name: String
    var body_type: String
    var features: Dictionary
    var behavior: String
    var stats: Dictionary
    var color_primary: Color
    var color_secondary: Color
    
    func _init():
        features = {}
        stats = {}

func generate_creature(difficulty: float) -> CreatureDefinition:
    var creature := CreatureDefinition.new()
    
    # Generate a Lovecraftian name
    creature.name = generate_creature_name()
    
    # Select body type and main features
    creature.body_type = body_types[rng.randi() % body_types.size()]
    
    # Generate features based on difficulty
    var num_features := int(difficulty * 3) + 1
    for _i in range(num_features):
        var feature := feature_types[rng.randi() % feature_types.size()]
        var count := rng.randi_range(1, int(difficulty * 2) + 1)
        creature.features[feature] = count
    
    # Select behavior pattern
    creature.behavior = behavior_patterns[rng.randi() % behavior_patterns.size()]
    
    # Generate stats based on difficulty
    creature.stats = {
        "hp": int(10 * difficulty),
        "damage": int(2 * difficulty),
        "speed": int(32 * (1 + (difficulty - 1) * 0.2)),
        "sanity_damage": int(difficulty)
    }
    
    # Generate colors
    creature.color_primary = Globals.get_random_color("dark")
    creature.color_secondary = Globals.get_random_color("accent")
    
    return creature

func generate_creature_name() -> String:
    var syllables := [
        "cth", "nyar", "sho", "goth", "thul",
        "hu", "yog", "zoth", "oth", "aza"
    ]
    
    var name := ""
    var length := rng.randi_range(2, 4)
    
    for _i in range(length):
        name += syllables[rng.randi() % syllables.size()]
    
    # Capitalize first letter
    return name.capitalize()

func generate_behavior_tree(creature: CreatureDefinition) -> Dictionary:
    var tree := {}
    
    match creature.behavior:
        "aggressive":
            tree = {
                "type": "sequence",
                "children": [
                    {
                        "type": "condition",
                        "check": "player_in_range",
                        "range": creature.stats.speed * 2
                    },
                    {
                        "type": "action",
                        "action": "move_towards_player"
                    },
                    {
                        "type": "action",
                        "action": "attack"
                    }
                ]
            }
        "stalking":
            tree = {
                "type": "selector",
                "children": [
                    {
                        "type": "sequence",
                        "children": [
                            {
                                "type": "condition",
                                "check": "player_in_sight"
                            },
                            {
                                "type": "condition",
                                "check": "player_not_looking"
                            },
                            {
                                "type": "action",
                                "action": "move_towards_player"
                            }
                        ]
                    },
                    {
                        "type": "action",
                        "action": "hide"
                    }
                ]
            }
        "territorial":
            tree = {
                "type": "sequence",
                "children": [
                    {
                        "type": "condition",
                        "check": "player_in_territory"
                    },
                    {
                        "type": "action",
                        "action": "defend_position"
                    }
                ]
            }
        "erratic":
            tree = {
                "type": "random",
                "children": [
                    {
                        "type": "action",
                        "action": "move_random"
                    },
                    {
                        "type": "action",
                        "action": "teleport_near_player"
                    },
                    {
                        "type": "action",
                        "action": "spawn_decoy"
                    }
                ]
            }
    
    return tree

func generate_attack_pattern(creature: CreatureDefinition) -> Dictionary:
    var pattern := {}
    
    # Base attack properties
    pattern.base_damage = creature.stats.damage
    pattern.range = creature.stats.speed
    
    # Special effects based on features
    if creature.features.has("tentacles"):
        pattern.grab_chance = 0.3
        pattern.grab_damage = creature.stats.damage * 0.5
    
    if creature.features.has("eyes"):
        pattern.gaze_effect = {
            "sanity_damage": creature.stats.sanity_damage,
            "range": creature.stats.speed * 1.5
        }
    
    if creature.features.has("mouths"):
        pattern.bite_effect = {
            "damage": creature.stats.damage * 1.5,
            "range": creature.stats.speed * 0.5
        }
    
    return pattern

func generate_movement_pattern(creature: CreatureDefinition) -> Dictionary:
    var pattern := {}
    
    pattern.base_speed = creature.stats.speed
    
    match creature.body_type:
        "amorphous":
            pattern.movement_type = "flow"
            pattern.can_squeeze = true
        "humanoid":
            pattern.movement_type = "walk"
            pattern.can_climb = true
        "insectoid":
            pattern.movement_type = "scuttle"
            pattern.can_wall_climb = true
        "tentacled":
            pattern.movement_type = "slither"
            pattern.can_grab_walls = true
    
    return pattern 