class_name Duckling
extends Duck


const EXCLAMATION_MARK_COLOR := Color("dec535")
const EXCLAMATION_MARK_WIDTH_START := 4.0
const EXCLAMATION_MARK_LENGTH_START := 24.0
const EXCLAMATION_MARK_STROKE_WIDTH_START := 1.2
const EXCLAMATION_MARK_DURATION := 1.8

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
            movement_params.collider_half_width_height.y,
            EXCLAMATION_MARK_COLOR,
            EXCLAMATION_MARK_WIDTH_START,
            EXCLAMATION_MARK_LENGTH_START,
            EXCLAMATION_MARK_STROKE_WIDTH_START,
            EXCLAMATION_MARK_DURATION))


func on_attached_to_leader() -> void:
    _show_exclamation_mark()
    
    # FIXME: ----------------------
    # - Trigger sound


func on_detached_from_leader() -> void:
    _show_exclamation_mark()
    
    # FIXME: ----------------------
    # - Trigger sound


func on_touched_enemy(enemy: KinematicBody2D) -> void:
    if start_surface == null:
        return
    
    _show_exclamation_mark()
    
    # FIXME: ----------------------
    # - Trigger sound
    
    if is_logging_events:
        Gs.logger.print("Duckling touched an enemy")
    
    if is_attached_to_leader:
        Gs.level.last_attached_duck = leader
        leader.is_attached_to_follower = false
        leader.just_attached_to_follower = false
        leader.just_detached_from_follower = true
        leader.follower = null
        just_attached_to_leader = false
        just_detached_from_leader = true
    if is_attached_to_follower:
        follower.on_leader_detached()
        just_attached_to_follower = false
        just_detached_from_follower = true
    
    is_attached_to_leader = false
    leader = null
    is_attached_to_follower = false
    follower = null
    
    Gs.level.swap_duckling_with_run_away(self, enemy)


func _on_PondDetectionArea_area_entered(area: Area2D) -> void:
    if is_fake or \
            !Gs.level.is_momma_level_started:
        return
    
    # FIXME: ---------------
    # - check if all ducklings and momma are in pond; if so, trigger win.
    pass
