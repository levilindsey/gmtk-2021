class_name Duckling
extends Player


func _init().("momma") -> void:
    pass


func _process_sounds() -> void:
    if just_triggered_jump:
        Gs.audio.play_sound("jump")
    
    if surface_state.just_left_air:
        Gs.audio.play_sound("land")
