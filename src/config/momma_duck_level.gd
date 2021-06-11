tool
class_name MommaDuckLevel
extends SurfacerLevel


const DUCKLING_RESOURCE_PATH := "res://src/players/duckling/duckling.tscn"
const FOX_RESOURCE_PATH := "res://src/players/fox/fox.tscn"

const DUCKLING_SPAWN_POSITIONS_GROUP_NAME := "duckling_spawn_positions"
const FOX_SPAWN_POSITIONS_GROUP_NAME := "fox_spawn_positions"

var duckling_spawn_positions := []
var fox_spawn_positions := []

var momma: Momma
var fox: Fox
# Array<Duckling>
var ducklings := []
var last_attached_duck: Duck


#func _enter_tree() -> void:
#    pass


#func _load() -> void:
#    ._load()


func _start() -> void:
    ._start()
    
    momma = Surfacer.human_player
    last_attached_duck = momma
    
    duckling_spawn_positions = Gs.utils.get_all_nodes_in_group(
            DUCKLING_SPAWN_POSITIONS_GROUP_NAME)
    fox_spawn_positions = Gs.utils.get_all_nodes_in_group(
            FOX_SPAWN_POSITIONS_GROUP_NAME)
    
    for spawn_position in duckling_spawn_positions:
        var duckling: Duckling = add_player(
                DUCKLING_RESOURCE_PATH,
                spawn_position.position,
                false)
        ducklings.push_back(duckling)
        duckling.call_deferred("create_leash_annotator")


func _destroy() -> void:
    ._destroy()
    
    for duckling in ducklings:
        remove_player(duckling)
    ducklings.clear()
    
    if is_instance_valid(fox):
        remove_player(fox)
    
    if is_instance_valid(momma):
        remove_player(momma)


#func _on_initial_input() -> void:
#    ._on_initial_input()


#func quit(immediately := true) -> void:
#    .quit(immediately)


#func _on_intro_choreography_finished() -> void:
#    ._on_intro_choreography_finished()


func _physics_process(_delta: float) -> void:
    if !is_started or is_destroyed:
        return
    
    # FIXME: ------- Check that this gets called before any Duck._physics_process for this frame.
    momma.clear_just_changed_attachment()
    for duckling in ducklings:
        duckling.clear_just_changed_attachment()


func get_music_name() -> String:
    return "on_a_quest"


func get_slow_motion_music_name() -> String:
    # FIXME: Add slo-mo music
    return ""
