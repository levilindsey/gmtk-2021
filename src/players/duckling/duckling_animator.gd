class_name DucklingAnimator
extends PlayerAnimator


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
        $Walk,
        $Rest,
        $JumpFall,
        $JumpRise,
        $Swim,
    ]
    for sprite in sprites:
        sprite.visible = false
    
    # Show the current sprite.
    match animation_type:
        PlayerAnimationType.WALK:
            $Walk.visible = true
        PlayerAnimationType.REST:
            $Rest.visible = true
        PlayerAnimationType.JUMP_FALL:
            $JumpFall.visible = true
        PlayerAnimationType.JUMP_RISE:
            $JumpRise.visible = true
        MommaAnimator.SWIM_ANIMATION_TYPE:
            $Swim.visible = true
        _:
            Gs.logger.error()


func animation_type_to_name(animation_type: int) -> String:
    if animation_type >= 8:
        # TODO: This is a terrible hack. Fix the underlying framework to use
        #       strings.
        match animation_type:
            MommaAnimator.SWIM_ANIMATION_TYPE:
                return animator_params.swim_name
            _:
                Utils.error()
                return ""
    else:
        return .animation_type_to_name(animation_type)


func animation_type_to_playback_rate(animation_type: int) -> float:
    if animation_type >= 8:
        # TODO: This is a terrible hack. Fix the underlying framework to use
        #       strings.
        match animation_type:
            MommaAnimator.SWIM_ANIMATION_TYPE:
                return animator_params.swim_playback_rate
            _:
                Utils.error()
                return INF
    else:
        return .animation_type_to_playback_rate(animation_type)
