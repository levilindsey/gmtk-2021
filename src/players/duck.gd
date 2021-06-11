class_name Duck
extends Player


const MAX_LEASH_DISTANCE := 768.0
const MAX_LEASH_DISTANCE_SQUARED := MAX_LEASH_DISTANCE * MAX_LEASH_DISTANCE

var leader: Duck
var follower: Duck

var is_attached_to_leader := false
var just_attached_to_leader := false
var just_detached_from_leader := false

var is_attached_to_follower := false
var just_attached_to_follower := false
var just_detached_from_follower := false


func _init(player_name: String).(player_name) -> void:
    pass


func _update_surface_state(preserves_just_changed_state := false) -> void:
    ._update_surface_state(preserves_just_changed_state)
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
        assert(leader != null)
    else:
        assert(leader == null)
        assert(follower == null)
    
    if was_attached_to_leader:
        is_attached_to_leader = \
                position.distance_squared_to(leader.position) < \
                MAX_LEASH_DISTANCE_SQUARED
    else:
        is_attached_to_leader = \
                position.distance_squared_to(
                        Gs.level.last_attached_duck.position) < \
                MAX_LEASH_DISTANCE_SQUARED
    
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
