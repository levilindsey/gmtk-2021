tool
class_name MommaDuckLevel
extends SurfacerLevel


const DUCKLING_RESOURCE_PATH := "res://src/players/duckling/duckling.tscn"
const FOX_RESOURCE_PATH := "res://src/players/fox/fox.tscn"
const PORCUPINE_RESOURCE_PATH := "res://src/players/porcupine/porcupine.tscn"
const SPIDER_RESOURCE_PATH := "res://src/players/spider/spider.tscn"

const DUCKLING_SPAWN_POSITIONS_GROUP_NAME := "duckling_spawn_positions"
const FOX_SPAWN_POSITIONS_GROUP_NAME := "fox_spawn_positions"
const PORCUPINE_SPAWN_POSITIONS_GROUP_NAME := "porcupine_spawn_positions"
const SPIDER_SPAWN_POSITIONS_GROUP_NAME := "spider_spawn_positions"

var duckling_spawn_positions := []
var fox_spawn_positions := []
var porcupine_spawn_positions := []
var spider_spawn_positions := []

var momma: Momma
# Array<Duckling>
var ducklings := []
# Array<Fox>
var foxes := []
# Array<Porcupine>
var porcupines := []
# Array<Spider>
var spiders := []

var last_attached_duck: Duck
var is_momma_level_started := false


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
    porcupine_spawn_positions = Gs.utils.get_all_nodes_in_group(
            PORCUPINE_SPAWN_POSITIONS_GROUP_NAME)
    spider_spawn_positions = Gs.utils.get_all_nodes_in_group(
            SPIDER_SPAWN_POSITIONS_GROUP_NAME)
    
    for spawn_position in duckling_spawn_positions:
        var duckling: Duckling = add_player(
                DUCKLING_RESOURCE_PATH,
                spawn_position.position,
                false)
        ducklings.push_back(duckling)
        duckling.call_deferred("create_leash_annotator")
    
    for spawn_position in fox_spawn_positions:
        var fox: Fox = add_player(
                FOX_RESOURCE_PATH,
                spawn_position.position,
                false)
        foxes.push_back(fox)
    
    for spawn_position in porcupine_spawn_positions:
        var porcupine: Porcupine = add_player(
                PORCUPINE_RESOURCE_PATH,
                spawn_position.position,
                false)
        porcupines.push_back(porcupine)
    
    for spawn_position in spider_spawn_positions:
        var spider: Spider = add_spider(spawn_position.position)
        spiders.push_back(spider)
    
    call_deferred("_on_started")


func _on_started() -> void:
    is_momma_level_started = true


func _destroy() -> void:
    ._destroy()
    
    for duckling in ducklings:
        remove_player(duckling)
    ducklings.clear()
    
    for fox in foxes:
        remove_player(fox)
    foxes.clear()
    
    for spider in spiders:
        remove_player(spider)
    spiders.clear()
    
    for porcupine in porcupines:
        remove_player(porcupine)
    porcupines.clear()
    
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


func add_spider(position: Vector2) -> Spider:
    var player: Spider = Gs.utils.add_scene(
            self,
            SPIDER_RESOURCE_PATH,
            false,
            true)
    player.position = position
    add_child(player)
    return player


func get_music_name() -> String:
    return "on_a_quest"


func get_slow_motion_music_name() -> String:
    # FIXME: Add slo-mo music
    return ""
