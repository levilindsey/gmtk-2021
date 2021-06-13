tool
class_name Fox
extends Player
# This is a hazard that jumps at nearby ducklings, if momma isn't nearby.


const RUN_FROM_MOMMA_DISTANCE_THRESHOLD := 128.0
const RUN_FROM_MOMMA_DISTANCE_SQUARED_THRESHOLD := \
        RUN_FROM_MOMMA_DISTANCE_THRESHOLD * RUN_FROM_MOMMA_DISTANCE_THRESHOLD

const RUN_FROM_MOMMA_DESTINATION_DISTANCE := 256.0

const EXCLAMATION_MARK_COLOR := Color("ff6053")
const EXCLAMATION_MARK_WIDTH_START := 4.0
const EXCLAMATION_MARK_LENGTH_START := 24.0
const EXCLAMATION_MARK_STROKE_WIDTH_START := 1.2
const EXCLAMATION_MARK_DURATION := 1.8

export var wander_radius := 256.0
export var wander_pause_duration := 4.0

var start_position := Vector2.INF
var start_surface: Surface = null
var is_running_from_momma := false
var is_pouncing_on_duckling := false
var is_wandering := false
var last_navigation_end_time := 0
var target_duckling: Duckling

var is_logging_events := false


func _init().("fox") -> void:
    pass


func _ready() -> void:
    start_position = position


func _update_surface_state(preserves_just_changed_state := false) -> void:
    ._update_surface_state(preserves_just_changed_state)
    
    if surface_state.just_grabbed_floor and \
            start_surface == null:
        start_surface = surface_state.grabbed_surface


func _update_navigator(delta_scaled: float) -> void:
    ._update_navigator(delta_scaled)
    
    if start_surface == null:
        return
    
    var current_time := Gs.time.get_scaled_play_time()
    
    var distance_squared_to_momma := \
            position.distance_squared_to(Gs.level.momma.position)
    if distance_squared_to_momma <= RUN_FROM_MOMMA_DISTANCE_SQUARED_THRESHOLD:
        # Run from momma.
        _run_from_momma()
    elif is_pouncing_on_duckling:
        assert(target_duckling != null)
        if navigator.navigation_state.just_reached_end_of_edge and \
                surface_state.just_left_air:
            # -   We are currently navigating, and we just landed on a new
            #     surface.
            # -   Update the navigation to point to the current leader
            #     position.
            _pounce_on_duckling(target_duckling)
    elif navigator.just_reached_destination:
        is_running_from_momma = false
        is_wandering = false
        last_navigation_end_time = current_time
    
    if !navigator.is_currently_navigating and \
            current_time >= last_navigation_end_time + wander_pause_duration:
        _trigger_wander()


func _run_from_momma() -> void:
    if is_running_from_momma:
        if !navigator.is_currently_navigating or \
                navigator.navigation_state.just_reached_end_of_edge and \
                surface_state.just_left_air:
            _navigate_to_new_position_away_from_momma()
    else:
        _navigate_to_new_position_away_from_momma()
    
    is_running_from_momma = true
    is_pouncing_on_duckling = false
    target_duckling = null


func _navigate_to_new_position_away_from_momma() -> void:
    if is_logging_events:
        Gs.logger.print("Fox run-from-momma start")
    
    _show_exclamation_mark()
    
    var direction_away_from_momma: Vector2 = \
            Gs.level.momma.position.direction_to(position)
    var naive_target := \
            direction_away_from_momma * RUN_FROM_MOMMA_DESTINATION_DISTANCE
    var graph_destination_for_in_air_destination := SurfaceParser \
            .find_closest_position_on_a_surface(naive_target, self)
    # Offset the destination a little, and make it in-air, so the fox will jump
    # to it.
    var destination_target := \
            graph_destination_for_in_air_destination.target_point + \
            Vector2(0.0, -0.1)
    var destination := \
            PositionAlongSurfaceFactory.create_position_without_surface(
                    destination_target)
    
    var was_navigation_successful := navigator.navigate_to_position(
            destination, graph_destination_for_in_air_destination)
    if !was_navigation_successful:
        # Try again, but without the in-air destination.
        navigator.navigate_to_position(
                graph_destination_for_in_air_destination)


func _trigger_wander() -> void:
    if start_surface == null:
        return
    
    if is_logging_events:
        Gs.logger.print("Fox wander start")
    
    is_wandering = true
    var left_most_point := Gs.geometry.project_point_onto_surface(
            Vector2(start_position.x - wander_radius, 0.0), start_surface)
    var right_most_point := Gs.geometry.project_point_onto_surface(
            Vector2(start_position.x + wander_radius, 0.0), start_surface)
    var target_x := \
            randf() * (right_most_point.x - left_most_point.x) + \
            left_most_point.x
    var destination := PositionAlongSurfaceFactory \
            .create_position_offset_from_target_point(
                    Vector2(target_x, 0.0),
                    start_surface,
                    movement_params.collider_half_width_height,
                    true)
    navigator.navigate_to_position(destination)


func _process_sounds() -> void:
    if just_triggered_jump:
        Gs.audio.play_sound("duck_jump")
    
    if surface_state.just_left_air:
        Gs.audio.play_sound("duck_land")


func _on_DucklingDetectionArea_body_entered(duckling: Duckling):
    if _is_destroyed or \
            is_fake:
        return
    
    if is_logging_events:
        Gs.logger.print("Fox is close to duckling")
    
    if !Gs.level.is_momma_level_started or \
            is_running_from_momma or \
            is_pouncing_on_duckling:
        return
    
    var fox_distance_squared_to_momma := \
            self.position.distance_squared_to(Gs.level.momma.position)
    if fox_distance_squared_to_momma <= \
            RUN_FROM_MOMMA_DISTANCE_SQUARED_THRESHOLD:
        return
    
    var duckling_distance_squared_to_momma := \
            duckling.position.distance_squared_to(Gs.level.momma.position)
    if duckling_distance_squared_to_momma <= \
            RUN_FROM_MOMMA_DISTANCE_SQUARED_THRESHOLD:
        return
    
    _pounce_on_duckling(duckling)


func _pounce_on_duckling(duckling: Duckling) -> void:
    if is_logging_events:
        Gs.logger.print("Fox pounce-on-duckling start")
    
    _show_exclamation_mark()
    
    is_pouncing_on_duckling = true
    target_duckling = duckling
    
    var graph_destination_for_in_air_destination := \
            duckling.surface_state.center_position_along_surface if \
            duckling.surface_state.is_grabbing_a_surface else \
            SurfaceParser.find_closest_position_on_a_surface(
                    duckling.position,
                    self)
    # Offset the destination a little, and make it in-air, so the fox will jump
    # to it.
    var destination_target := \
            graph_destination_for_in_air_destination.target_point + \
            Vector2(0.0, -0.1)
    var destination := \
            PositionAlongSurfaceFactory.create_position_without_surface(
                    destination_target)
    
    navigator.navigate_to_position(
            destination, graph_destination_for_in_air_destination)


func _on_DuckCollisionDetectionArea_body_entered(duck: Duck) -> void:
    if _is_destroyed or \
            is_fake or \
            !Gs.level.is_momma_level_started:
        return
    
    if is_logging_events:
        Gs.logger.print("Fox collided with %s" % (
            "momma" if \
            duck is Momma else \
            "duckling"
        ))
    
    if duck is Momma:
        _run_from_momma()
        duck.on_touched_enemy(self)
    else:
        assert(duck is Duckling)
        if is_pouncing_on_duckling and \
                duck == target_duckling:
            is_pouncing_on_duckling = false
            target_duckling = null
            navigator.stop()
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
