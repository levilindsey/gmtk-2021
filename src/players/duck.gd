class_name Duck
extends Player


const LEASH_ATTACH_DISTANCE := 128.0
const LEASH_DETACH_DISTANCE := 400.0

const LEASH_ATTACH_DISTANCE_SQUARED := \
        LEASH_ATTACH_DISTANCE * LEASH_ATTACH_DISTANCE
const LEASH_DETACH_DISTANCE_SQUARED := \
        LEASH_DETACH_DISTANCE * LEASH_DETACH_DISTANCE

const CLOSE_ENOUGH_TO_STOP_NAVIGATING_DISTANCE := 64.0
const CLOSE_ENOUGH_TO_STOP_NAVIGATING_DISTANCE_SQUARED := \
        CLOSE_ENOUGH_TO_STOP_NAVIGATING_DISTANCE * \
        CLOSE_ENOUGH_TO_STOP_NAVIGATING_DISTANCE

const FAR_ENOUGH_TO_START_NAVIGATING_DISTANCE := 96.0
const FAR_ENOUGH_TO_START_NAVIGATING_DISTANCE_SQUARED := \
        FAR_ENOUGH_TO_START_NAVIGATING_DISTANCE * \
        FAR_ENOUGH_TO_START_NAVIGATING_DISTANCE

const QUACK_DURATION_DEFAULT := 0.4

var leader: Duck
var follower: Duck

var start_position := Vector2.INF
var start_surface: Surface

var is_in_pond := false
var is_quacking := false
var quack_timeout_id := -1

var is_attached_to_leader := false
var just_attached_to_leader := false
var just_detached_from_leader := false
var is_close_enough_to_leader_to_stop_moving := false
var is_far_enough_from_leader_to_start_moving := false

var is_attached_to_follower := false
var just_attached_to_follower := false
var just_detached_from_follower := false


func _init(player_name: String).(player_name) -> void:
    pass


func _ready() -> void:
    start_position = position


func _update_surface_state(preserves_just_changed_state := false) -> void:
    ._update_surface_state(preserves_just_changed_state)
    
    if surface_state.just_grabbed_floor and \
            start_surface == null:
        start_surface = surface_state.grabbed_surface
    
    _update_attachment()


func clear_just_changed_attachment() -> void:
    just_attached_to_follower = false
    just_detached_from_follower = false
    just_attached_to_leader = false
    just_detached_from_leader = false


func _update_attachment() -> void:
    var was_attached_to_leader := is_attached_to_leader
    var was_attached_to_follower := is_attached_to_follower
    
    if was_attached_to_leader:
        assert(is_instance_valid(leader))
    else:
        assert(leader == null)
        assert(follower == null)
    
    if was_attached_to_leader:
        is_attached_to_leader = \
                position.distance_squared_to(leader.position) < \
                LEASH_DETACH_DISTANCE_SQUARED
    else:
        is_attached_to_leader = \
                position.distance_squared_to(
                        Gs.level.last_attached_duck.position) < \
                LEASH_ATTACH_DISTANCE_SQUARED
    
    just_attached_to_leader = \
            !was_attached_to_leader and \
            is_attached_to_leader
    just_detached_from_leader = \
            was_attached_to_leader and \
            !is_attached_to_leader
    
    if just_attached_to_leader:
        leader = Gs.level.last_attached_duck
        Gs.level.last_attached_duck = self
        leader.is_attached_to_follower = true
        leader.just_attached_to_follower = true
        leader.just_detached_from_follower = false
        leader.follower = self
    elif just_detached_from_leader:
        leader.is_attached_to_follower = false
        leader.just_attached_to_follower = false
        leader.just_detached_from_follower = true
        leader.follower = null
        Gs.level.last_attached_duck = leader
        leader = null
        if is_attached_to_follower:
            follower.on_leader_detached()
    
    if is_attached_to_leader:
        var distance_squared_to_leader := \
                position.distance_squared_to(leader.position)
        is_close_enough_to_leader_to_stop_moving = \
                distance_squared_to_leader <= \
                CLOSE_ENOUGH_TO_STOP_NAVIGATING_DISTANCE_SQUARED
        is_far_enough_from_leader_to_start_moving = \
                distance_squared_to_leader <= \
                FAR_ENOUGH_TO_START_NAVIGATING_DISTANCE_SQUARED
    else:
        is_close_enough_to_leader_to_stop_moving = false
        is_far_enough_from_leader_to_start_moving = false
    
    if just_attached_to_leader:
        on_attached_to_leader()
    
    if just_detached_from_leader:
        on_detached_from_leader()


func on_leader_detached() -> void:
    leader.is_attached_to_follower = false
    leader.just_attached_to_follower = false
    leader.just_detached_from_follower = true
    leader.follower = null
    
    is_attached_to_leader = false
    just_attached_to_leader = false
    just_detached_from_leader = true
    leader = null
    
    if is_attached_to_follower:
        follower.on_leader_detached()
    
    if just_detached_from_leader:
        on_detached_from_leader()


func on_attached_to_leader() -> void:
    pass


func on_detached_from_leader() -> void:
    pass


func on_touched_enemy(enemy: KinematicBody2D) -> void:
    pass


func _on_PondDetectionArea_area_entered(area: Area2D) -> void:
    if _is_destroyed or \
            is_fake or \
            !Gs.level.is_momma_level_started:
        return
    
    is_in_pond = true
    Gs.level.check_if_all_ducks_are_in_pond()


func _on_PondDetectionArea_area_exited(area: Area2D) -> void:
    if _is_destroyed or \
            is_fake or \
            !Gs.level.is_momma_level_started:
        return
    
    is_in_pond = false


func _quack() -> void:
    is_quacking = true
    var duration: float = \
            QUACK_DURATION_DEFAULT / \
            movement_params.animator_params.quack_playback_rate
    Gs.time.clear_timeout(quack_timeout_id)
    quack_timeout_id = Gs.time.set_timeout(
                funcref(self, "_on_quack_completed"), duration)
    
    # FIXME: ---------------
    # - play sound
    pass


func _on_quack_completed() -> void:
    is_quacking = false
    _process_animation()


func _process_animation() -> void:
    if is_in_pond:
        animator.play(MommaAnimator.SWIM_ANIMATION_TYPE)
    elif is_quacking:
        animator.play(MommaAnimator.QUACK_ANIMATION_TYPE)
    else:
        ._process_animation()
