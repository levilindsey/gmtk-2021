class_name SpiderAnimator
extends PlayerAnimator


var is_facing_down := true


func set_static_frame(animation_state: PlayerAnimationState) -> void:
    _show_sprite(animation_state.animation_type)
    .set_static_frame(animation_state)


func _play_animation(
        animation_type: int,
        blend := 0.1) -> bool:
    _show_sprite(animation_type)
    return ._play_animation(animation_type, blend)


func _show_sprite(animation_type: int) -> void:
    # Hide the other sprites.
    var sprites := [
        $ClimbUp,
        $ClimbDown,
        $RestUp,
        $RestDown,
    ]
    for sprite in sprites:
        sprite.visible = false
    
    # Show the current sprite.
    match animation_type:
        PlayerAnimationType.CLIMB_UP:
            $ClimbUp.visible = true
        PlayerAnimationType.CLIMB_DOWN:
            $ClimbDown.visible = true
        PlayerAnimationType.REST:
            if is_facing_down:
                $RestDown.visible = true
            else:
                $RestUp.visible = true
        _:
            Gs.logger.error()
