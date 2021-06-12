class_name Porcupine
extends Player
# This is a hazard that moves side-to-side along a surface.


const DISTANCE_FROM_END_FOR_TURN_AROUND := 20.0

const RUN_FROM_MOMMA_DISTANCE_THRESHOLD := 256.0
const RUN_FROM_MOMMA_DISTANCE_SQUARED_THRESHOLD := \
        RUN_FROM_MOMMA_DISTANCE_THRESHOLD * RUN_FROM_MOMMA_DISTANCE_THRESHOLD

var just_turned := false
var is_walking_left := false
var start_position := Vector2.INF
var surface: Surface


func _init().("porcupine") -> void:
    pass


func _ready() -> void:
    start_position = position


func _update_surface_state(preserves_just_changed_state := false) -> void:
    ._update_surface_state(preserves_just_changed_state)
    
    if surface_state.just_grabbed_floor and \
            surface == null:
        surface = surface_state.grabbed_surface


func _update_navigator(delta_scaled: float) -> void:
    ._update_navigator(delta_scaled)
    
    if surface == null:
        return
    
    just_turned = false
    
    var left_end := surface.first_point
    var right_end := surface.last_point
    
    var new_destination: PositionAlongSurface
    if position.x <= left_end.x + DISTANCE_FROM_END_FOR_TURN_AROUND:
        is_walking_left = false
        new_destination = PositionAlongSurfaceFactory \
                .create_position_offset_from_target_point(
                        left_end,
                        surface,
                        movement_params.collider_half_width_height,
                        true)
    elif position.x >= right_end.x - DISTANCE_FROM_END_FOR_TURN_AROUND:
        is_walking_left = true
        new_destination = PositionAlongSurfaceFactory \
                .create_position_offset_from_target_point(
                        left_end,
                        surface,
                        movement_params.collider_half_width_height,
                        true)
    
    if new_destination != null:
        just_turned = true
        navigator.navigate_to_position(new_destination)
    
    if !just_turned:
        var distance_squared_to_momma := \
                position.distance_squared_to(Gs.level.momma.position)
        if distance_squared_to_momma <= \
                RUN_FROM_MOMMA_DISTANCE_SQUARED_THRESHOLD:
            # Run from momma.
            _walk_away_from_momma()


func _walk_away_from_momma() -> void:
    if surface == null:
        return
    
    var is_momma_to_the_left: bool = Gs.level.momma.position.x < position.x
    if is_momma_to_the_left == is_walking_left:
        is_walking_left = !is_walking_left
        just_turned = true
        
        var end_target_point := \
                surface.first_point if \
                is_walking_left else \
                surface.last_point
        var destination := PositionAlongSurfaceFactory \
                .create_position_offset_from_target_point(
                        end_target_point,
                        surface,
                        movement_params.collider_half_width_height,
                        true)
        navigator.navigate_to_position(destination)


func _on_DuckCollisionDetectionArea_body_entered(duck: Duck) -> void:
    if !Gs.level.is_momma_level_started:
        return
    
    if duck is Momma:
        _walk_away_from_momma()
        duck.on_touched_enemy(self)
    else:
        assert(duck is Duckling)
        duck.on_touched_enemy(self)
