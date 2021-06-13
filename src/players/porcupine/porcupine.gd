class_name Porcupine
extends Player
# This is a hazard that moves side-to-side along a surface.


# NOTE: This should be slightly wider than half the porcupine width, to prevent
#       a problem with the edge case of concave neigbor walls.
const DISTANCE_FROM_END_FOR_TURN_AROUND := 25.0

const RUN_FROM_MOMMA_DISTANCE_THRESHOLD := 128.0
const RUN_FROM_MOMMA_DISTANCE_SQUARED_THRESHOLD := \
        RUN_FROM_MOMMA_DISTANCE_THRESHOLD * RUN_FROM_MOMMA_DISTANCE_THRESHOLD

const EXCLAMATION_MARK_COLOR := Color("262626")
const EXCLAMATION_MARK_WIDTH_START := 4.0
const EXCLAMATION_MARK_LENGTH_START := 24.0
const EXCLAMATION_MARK_STROKE_WIDTH_START := 1.2
const EXCLAMATION_MARK_DURATION := 1.8

var just_turned := false
var is_walking_left := false
var start_position := Vector2.INF
var surface: Surface

var is_logging_events := false


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
    if is_walking_left and \
            position.x <= left_end.x + DISTANCE_FROM_END_FOR_TURN_AROUND:
        is_walking_left = false
        new_destination = PositionAlongSurfaceFactory \
                .create_position_offset_from_target_point(
                        right_end,
                        surface,
                        movement_params.collider_half_width_height,
                        true)
    elif !is_walking_left and \
            position.x >= right_end.x - DISTANCE_FROM_END_FOR_TURN_AROUND:
        is_walking_left = true
        new_destination = PositionAlongSurfaceFactory \
                .create_position_offset_from_target_point(
                        left_end,
                        surface,
                        movement_params.collider_half_width_height,
                        true)
    
    var was_navigating := navigator.is_currently_navigating
    if new_destination == null and \
            !was_navigating:
        is_walking_left = !is_walking_left
        var target_end := left_end if is_walking_left else right_end
        new_destination = PositionAlongSurfaceFactory \
                .create_position_offset_from_target_point(
                        target_end,
                        surface,
                        movement_params.collider_half_width_height,
                        true)
    
    if new_destination != null:
        if is_logging_events:
            Gs.logger.print(
                    ("Porcupine just turned: " +
                    "is_walking_left=%s, " +
                    "was_navigating=%s") % \
                    [is_walking_left, was_navigating])
        
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
        if is_logging_events:
            Gs.logger.print("Porcupine walk-away-from-momma start")
        
        _show_exclamation_mark()
        
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
    if _is_destroyed or \
            is_fake or \
            !Gs.level.is_momma_level_started:
        return
    
    if is_logging_events:
        Gs.logger.print("Porcupine collided with %s" % (
            "momma" if \
            duck is Momma else \
            "duckling"
        ))
    
    if duck is Momma:
        _walk_away_from_momma()
        duck.on_touched_enemy(self)
    else:
        assert(duck is Duckling)
        duck.on_touched_enemy(self)


func _show_exclamation_mark() -> void:
    Surfacer.annotators.add_transient(ExclamationMarkAnnotator.new(
            self,
            movement_params.collider_half_width_height.y,
            EXCLAMATION_MARK_COLOR,
            EXCLAMATION_MARK_WIDTH_START,
            EXCLAMATION_MARK_LENGTH_START,
            EXCLAMATION_MARK_STROKE_WIDTH_START,
            EXCLAMATION_MARK_DURATION))
