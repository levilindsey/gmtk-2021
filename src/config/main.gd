class_name Main
extends SurfacerBootstrap


func _ready() -> void:
    run(MommaDuck.app_manifest, self)


#func _amend_app_manifest() -> void:
#    ._amend_app_manifest()


#func _register_app_manifest() -> void:
#    ._register_app_manifest()


func _initialize_framework() -> void:
    ._initialize_framework()
    MommaDuck.initialize()
    
    # FIXME: -------------- REMOVE
#    Gs.save_state.erase_all_state()
#    for id in Gs.level_config.get_level_ids():
#        Gs.save_state.set_level_is_unlocked(id, false)
#        Gs.save_state.erase_level_state(id)
#    get_tree().quit()


func _on_app_initialized() -> void:
    ._on_app_initialized()
    
    # Hide this annatotator by default.
    Surfacer.annotators.set_annotator_enabled(
            AnnotatorType.RECENT_MOVEMENT,
            false)


#func _on_splash_finished() -> void:
#    ._on_splash_finished()
