class_name Duckling
extends Duck


var leash_annotator: LeashAnnotator


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
            if navigator.navigation_state.just_reached_end_of_edge and \
                    surface_state.just_left_air:
                # -   We are currently navigating, and we just landed on a new
                #     surface.
                # -   Update the navigation to point to the current leader
                #     position.
                _trigger_new_navigation()
        else:
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
