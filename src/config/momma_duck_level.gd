tool
class_name MommaDuckLevel
extends SurfacerLevel


const DUCKLING_RESOURCE_PATH := "res://src/players/duckling/duckling.tscn"
const RUN_AWAY_DUCKLING_RESOURCE_PATH := \
        "res://src/players/run_away_duckling/run_away_duckling.tscn"
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
# Array<RunAwayDuckling>
var run_away_ducklings := []
# Array<Fox>
var foxes := []
# Array<Porcupine>
var porcupines := []
# Array<Spider>
var spiders := []

var last_attached_duck: Duck
var is_momma_level_started := false
var is_over := false


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
        duckling.call_deferred("create_leash_annotator")
        ducklings.push_back(duckling)

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
    for duckling in ducklings:
        remove_player(duckling)
    ducklings.clear()
    
    for fox in foxes:
        remove_player(fox)
    foxes.clear()
    
    for spider in spiders:
        remove_spider(spider)
    spiders.clear()
    
    for porcupine in porcupines:
        remove_player(porcupine)
    porcupines.clear()
    
    if is_instance_valid(momma):
        remove_player(momma)
    
    ._destroy()


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


func remove_spider(spider: Spider) -> void:
    spider._destroy()
    remove_child(spider)


func swap_duckling_with_run_away(
        duckling: Duckling,
        enemy: KinematicBody2D) -> void:
    assert(duckling.start_surface != null)
    
    var run_away_origin := duckling.position
    var run_away_destination := PositionAlongSurfaceFactory. \
            create_position_offset_from_target_point(
                    duckling.start_position,
                    duckling.start_surface,
                    duckling.movement_params.collider_half_width_height,
                    true)
    
    ducklings.erase(duckling)
    remove_player(duckling)
    
    var run_away_duckling: RunAwayDuckling = add_player(
            RUN_AWAY_DUCKLING_RESOURCE_PATH,
            run_away_origin,
            false)
    run_away_ducklings.push_back(run_away_duckling)
    run_away_duckling.run_away(run_away_destination, enemy)


func swap_run_away_with_duckling(run_away_duckling: RunAwayDuckling) -> void:
    var position := run_away_duckling.position
    
    run_away_ducklings.erase(run_away_duckling)
    remove_player(run_away_duckling)
    
    var duckling: Duckling = add_player(
            DUCKLING_RESOURCE_PATH,
            position,
            false)
    duckling.call_deferred("create_leash_annotator")
    ducklings.push_back(duckling)


func check_if_all_ducks_are_in_pond() -> void:
    if !momma.is_in_pond:
        return
    
    for duckling in ducklings:
        if !duckling.is_in_pond:
            return
    
    trigger_level_victory()


func trigger_level_victory() -> void:
    if !is_over:
        is_over = true
        quit(false)


func _record_level_results() -> void:
    ._record_level_results()
    
    var level_fastest_time_settings_key := \
            get_level_fastest_time_settings_key(_id)
    var time := _get_level_play_time_unscaled()
    var previous_fastest_time: float = Gs.save_state.get_setting(
            level_fastest_time_settings_key,
            INF)
    var reached_new_fastest_time := time < previous_fastest_time
    if reached_new_fastest_time:
        Gs.save_state.set_setting(
                level_fastest_time_settings_key,
                time)


func get_music_name() -> String:
    return "on_a_quest"


func get_slow_motion_music_name() -> String:
    # FIXME: Add slo-mo music
    return ""


static func get_level_fastest_time_settings_key(level_id: String) -> String:
    return "level_%s_fastest_time" % level_id
