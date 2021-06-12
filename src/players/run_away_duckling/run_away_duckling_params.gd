class_name RunAwayDucklingParams
extends DucklingParams


func _init_params() -> void:
    ._init_params()
    
    name = "run_away_duckling"
    player_resource_path = \
            "res://src/players/run_away_duckling/run_away_duckling.tscn"
    
    gravity_fast_fall = Gs.geometry.GRAVITY * 1.0
    
    jump_boost *= 2.0
    in_air_horizontal_acceleration *= 2.0
    walk_acceleration *= 3.0
    
    max_horizontal_speed_default *= 2.0
    max_vertical_speed *= 1.5
    
    uses_duration_instead_of_distance_for_edge_weight = true
    additional_edge_weight_offset = 128.0
    walking_edge_weight_multiplier = 1.2
    climbing_edge_weight_multiplier = 1.8
    air_edge_weight_multiplier = 1.0


func _init_animator_params() -> void:
    animator_params = PlayerAnimatorParams.new()
    
    animator_params.player_animator_scene_path = \
            "res://src/players/run_away_duckling/run_away_duckling_animator.tscn"
    
    animator_params.faces_right_by_default = false
    
    animator_params.rest_name = "Rest"
    animator_params.rest_on_wall_name = "RestOnWall"
    animator_params.jump_rise_name = "JumpRise"
    animator_params.jump_fall_name = "JumpFall"
    animator_params.walk_name = "Walk"
    animator_params.climb_up_name = "ClimbUp"
    animator_params.climb_down_name = "ClimbDown"

    animator_params.rest_playback_rate = 0.8
    animator_params.rest_on_wall_playback_rate = 0.8
    animator_params.jump_rise_playback_rate = 1.0
    animator_params.jump_fall_playback_rate = 1.0
    animator_params.walk_playback_rate = 20.0
    animator_params.climb_up_playback_rate = 9.4
    animator_params.climb_down_playback_rate = \
            -animator_params.climb_up_playback_rate / 2.33
