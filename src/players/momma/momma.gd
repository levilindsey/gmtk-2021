class_name Momma
extends Duck


var leash_attachment_offset := Vector2(11.0, -5.0)


func _init().("momma") -> void:
    pass


func _update_attachment() -> void:
    is_attached_to_leader = true
    leader = self


func _process_sounds() -> void:
    if just_triggered_jump:
        Gs.audio.play_sound("duck_jump")
    
    if surface_state.just_left_air:
        Gs.audio.play_sound("duck_land")


func on_touched_enemy(enemy: KinematicBody2D) -> void:
    _quack()
