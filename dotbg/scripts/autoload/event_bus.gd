extends Node

# Player Events
signal player_spawned(position: Vector3)
signal player_died
signal interaction_attempted(position: Vector3)
signal inventory_toggle_requested

# Combat Events
signal enemy_killed(enemy_id: String, position: Vector2)
signal player_hit(damage: float)
signal weapon_switched(weapon_id: String)

# World Events
signal room_entered(room_id: String)
signal room_cleared()
signal checkpoint_reached(checkpoint_id: String)
signal item_collected(item_id: String)
signal door_opened(door_id: String)
signal secret_found(secret_id: String)

# Sanity Events
signal sanity_effect_triggered(effect_id: String)
signal hallucination_spawned(type: String, position: Vector2)
signal reality_distortion(intensity: float)

# Story Events
signal lore_discovered(lore_id: String)
signal npc_interaction_started(npc_id: String)
signal npc_interaction_ended(npc_id: String)
signal quest_updated(quest_id: String, stage: int)
signal memory_echo_triggered(memory_id: String)

# UI Events
signal show_dialog(text: String, speaker: String)
signal hide_dialog()
signal show_tooltip(text: String, position: Vector2)
signal hide_tooltip()
signal update_objective(text: String)

# System Events
signal save_game_requested()
signal load_game_requested()
signal settings_changed()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS 
