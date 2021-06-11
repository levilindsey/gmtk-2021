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


func _process_sounds() -> void:
    if just_triggered_jump:
        Gs.audio.play_sound("jump")
    
    if surface_state.just_left_air:
        Gs.audio.play_sound("land")
