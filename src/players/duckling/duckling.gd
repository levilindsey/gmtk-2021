class_name Duckling
extends Duck


var EXCLAMATION_MARK_WIDTH_START := 4.0
var EXCLAMATION_MARK_LENGTH_START := 24.0
var EXCLAMATION_MARK_STROKE_WIDTH_START := 1.2
var EXCLAMATION_MARK_DURATION := 1.8

var leash_annotator: LeashAnnotator

var is_logging_events := false


func _init().("duckling") -> void:
    pass


func create_leash_annotator() -> void:
    leash_annotator = LeashAnnotator.new(self)
    Surfacer.annotators.get_player_annotator(self).add_child(leash_annotator)


func _destroy() -> void:
    if is_instance_valid(leash_annotator):
        leash_annotator.queue_free()
    ._destroy()


func _update_navigator(delta_scaled: float) -> void:
    ._update_navigator(delta_scaled)
    
    if is_attached_to_leader:
        if navigator.is_currently_navigating:
            if is_close_enough_to_leader_to_stop_moving:
                navigator.stop()
            elif navigator.navigation_state.just_reached_end_of_edge and \
                    surface_state.just_left_air:
                # -   We are currently navigating, and we just landed on a new
                #     surface.
                # -   Update the navigation to point to the current leader
                #     position.
                _trigger_new_navigation()
        elif !is_far_enough_from_leader_to_start_moving:
            # We weren't yet navigating anywhere, so start navigating to the
            # leader.
            _trigger_new_navigation()


func _trigger_new_navigation() -> void:
    var destination: PositionAlongSurface
    if leader.surface_state.is_grabbing_a_surface:
        destination = leader.surface_state.center_position_along_surface
    else:
        destination = SurfaceParser.find_closest_position_on_a_surface(
                leader.position, leader)
    navigator.navigate_to_position(destination)


func _process_sounds() -> void:
    if just_triggered_jump:
        Gs.audio.play_sound("jump")
    
    if surface_state.just_left_air:
        Gs.audio.play_sound("land")


func _show_exclamation_mark() -> void:
    Surfacer.annotators.add_transient(ExclamationMarkAnnotator.new(
            self,
            EXCLAMATION_MARK_WIDTH_START,
            EXCLAMATION_MARK_LENGTH_START,
            EXCLAMATION_MARK_STROKE_WIDTH_START,
            EXCLAMATION_MARK_DURATION))


func on_attached_to_leader() -> void:
    _show_exclamation_mark()


func on_detached_from_leader() -> void:
    _show_exclamation_mark()


func on_touched_enemy(enemy: KinematicBody2D) -> void:
    _show_exclamation_mark()
    
    if start_surface == null:
        return
    
    var destination := PositionAlongSurfaceFactory \
            .create_position_offset_from_target_point(
                    start_position,
                    start_surface,
                    movement_params.collider_half_width_height,
                    true)
    navigator.navigate_to_position(destination)
    
    # FIXME: ----------------------
    # - Swap self with a run_away_duckling player.
    # - Run back to spawn point
    #   - Swap run_away_duckling with duckling when reached destination.
    # - Trigger sound


func _on_PondDetectionArea_area_entered(area: Area2D) -> void:
    if is_fake or \
            !Gs.level.is_momma_level_started:
        return
    
    # FIXME: ---------------
    # - check if all ducklings and momma are in pond; if so, trigger win.
    pass
