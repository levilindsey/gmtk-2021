class_name Gmtk21Player
extends Player


func _init().("gmtk21_player") -> void:
    pass


func _process_sounds() -> void:
    if just_triggered_jump:
        Gs.audio.play_sound("jump")
    
    if surface_state.just_left_air:
        Gs.audio.play_sound("land")
