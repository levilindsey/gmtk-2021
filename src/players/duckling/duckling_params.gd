class_name DucklingParams
extends MommaParams


func _init_params() -> void:
    ._init_params()

    name = "duckling"
    player_resource_path = \
    "res://src/players/duckling/duckling.tscn"
    
    collider_shape.radius = 8.0
    
    fall_from_floor_corner_calc_shape.extents = \
            Vector2(collider_shape.radius, collider_shape.radius)
    
    gravity_fast_fall = Gs.geometry.GRAVITY * 0.8
    
    jump_boost *= 0.8
    in_air_horizontal_acceleration *= 0.8
    walk_acceleration *= 0.7
    
    max_horizontal_speed_default *= 0.7
    max_vertical_speed *= 0.8
    
    uses_duration_instead_of_distance_for_edge_weight = true
    additional_edge_weight_offset = 128.0
    walking_edge_weight_multiplier = 1.2
    climbing_edge_weight_multiplier = 1.8
    air_edge_weight_multiplier = 1.0


func _init_animator_params() -> void:
    animator_params = DuckAnimatorParams.new()
    
    animator_params.player_animator_scene_path = \
            "res://src/players/duckling/duckling_animator.tscn"
    
    animator_params.faces_right_by_default = false
    
    animator_params.rest_name = "Rest"
    animator_params.rest_on_wall_name = "RestOnWall"
    animator_params.jump_rise_name = "JumpRise"
    animator_params.jump_fall_name = "JumpFall"
    animator_params.walk_name = "Walk"
    animator_params.climb_up_name = "ClimbUp"
    animator_params.climb_down_name = "ClimbDown"
    animator_params.swim_name = "Swim"

    animator_params.rest_playback_rate = 0.8
    animator_params.rest_on_wall_playback_rate = 0.8
    animator_params.jump_rise_playback_rate = 1.0
    animator_params.jump_fall_playback_rate = 1.0
    animator_params.walk_playback_rate = 20.0
    animator_params.climb_up_playback_rate = 9.4
    animator_params.climb_down_playback_rate = \
            -animator_params.climb_up_playback_rate / 2.33
    animator_params.swim_playback_rate = 1.0
