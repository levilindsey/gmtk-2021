class_name RunAwayDuckling
extends Player


var destination: PositionAlongSurface

var is_logging_events := false


func _init().("run_away_duckling") -> void:
    pass


func run_away(
        destination: PositionAlongSurface,
        enemy: KinematicBody2D) -> void:
    self.destination = destination
    
    # The newly-created surface-state thinks we're in-air anyway, so let's make
    # it a little more real.
    self.set_position(position + Vector2(0.0, -0.1))
    
    # Give the run-away an initial jump away from the enemy.
    velocity.y = movement_params.jump_boost
    velocity.x = movement_params.max_horizontal_speed_default * 0.5
    var is_left_of_enemy := position.x < enemy.position.x
    if is_left_of_enemy:
        velocity.x *= -1
    
    navigator.connect("destination_reached", self, "_on_destination_reached")
    var did_navigation_succeed := navigator.navigate_to_position(destination)
    if !did_navigation_succeed:
        Gs.logger.print("Run-away navigation path-finding was not successful")
        Gs.level.swap_run_away_with_duckling(self)
    
    _show_exclamation_mark()


func _on_destination_reached() -> void:
    if is_logging_events:
        Gs.logger.print("Run-away reached spawn position")
    Gs.level.swap_run_away_with_duckling(self)


func _process_sounds() -> void:
    if just_triggered_jump:
        Gs.audio.play_sound("duck_jump")
    
    if surface_state.just_left_air:
        Gs.audio.play_sound("duck_land")


func _show_exclamation_mark() -> void:
    Surfacer.annotators.add_transient(ExclamationMarkAnnotator.new(
            self,
            movement_params.collider_half_width_height.y,
            Duckling.EXCLAMATION_MARK_COLOR,
            Duckling.EXCLAMATION_MARK_WIDTH_START,
            Duckling.EXCLAMATION_MARK_LENGTH_START,
            Duckling.EXCLAMATION_MARK_STROKE_WIDTH_START,
            Duckling.EXCLAMATION_MARK_DURATION))
