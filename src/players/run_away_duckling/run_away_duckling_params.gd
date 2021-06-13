class_name RunAwayDucklingParams
extends DucklingParams


func _init_params() -> void:
    ._init_params()
    
    name = "run_away_duckling"
    player_resource_path = \
            "res://src/players/run_away_duckling/run_away_duckling.tscn"
    
#    gravity_fast_fall = Gs.geometry.GRAVITY * 1.0
    
#    jump_boost *= 1.15
    in_air_horizontal_acceleration *= 2.0
    walk_acceleration *= 3.0
    
    max_horizontal_speed_default *= 2.0
#    max_vertical_speed *= 1.5
    
    uses_duration_instead_of_distance_for_edge_weight = true
    additional_edge_weight_offset = 128.0
    walking_edge_weight_multiplier = 1.2
    climbing_edge_weight_multiplier = 1.8
    air_edge_weight_multiplier = 1.0
