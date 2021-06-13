class_name MommaDuckLevelConfig
extends SurfacerLevelConfig


const ARE_LEVELS_SCENE_BASED := true

const LEVELS_PATH_PREFIX := "res://src/levels/"

var level_manifest := {
#    "1": {
#        name = "Level 1",
#        version = "0.0.1",
#        priority = 100,
#        scene_path = LEVELS_PATH_PREFIX + "level1.tscn",
#        platform_graph_player_names = [
#            "momma",
#            "duckling",
#            "run_away_duckling",
#            "porcupine",
#            "fox",
#        ],
#        intro_choreography = [
#            {
#                is_user_interaction_enabled = false,
#                zoom = 0.5,
#            },
#            {
#                duration = 0.3,
#            },
#            {
#                destination = SurfacerLevelConfig \
#                        .INTRO_CHOREOGRAPHY_DESTINATION_GROUP_NAME,
#            },
#            {
#                duration = 0.4,
#                zoom = 1.0,
#            },
#            {
#                is_user_interaction_enabled = true,
#            },
#        ],
#    },
    "1": {
        name = "Search",
        version = "0.0.1",
        priority = 10,
        scene_path = LEVELS_PATH_PREFIX + "level1.tscn",
        platform_graph_player_names = [
            "momma",
            "duckling",
            "run_away_duckling",
        ],
        intro_choreography = [
            {
                is_user_interaction_enabled = false,
                zoom = 0.5,
            },
            {
                duration = 0.3,
            },
            {
                destination = SurfacerLevelConfig \
                        .INTRO_CHOREOGRAPHY_DESTINATION_GROUP_NAME,
            },
            {
                duration = 0.4,
                zoom = 1.0,
            },
            {
                is_user_interaction_enabled = true,
            },
        ],
    },
    "2": {
        name = "Tend",
        version = "0.0.1",
        priority = 20,
        scene_path = LEVELS_PATH_PREFIX + "level2.tscn",
        platform_graph_player_names = [
            "momma",
            "duckling",
            "run_away_duckling",
        ],
    },
    "3": {
        name = "Avoid",
        version = "0.0.1",
        priority = 30,
        scene_path = LEVELS_PATH_PREFIX + "level3.tscn",
        platform_graph_player_names = [
            "momma",
            "duckling",
            "run_away_duckling",
            "porcupine",
        ],
    },
    "4": {
        name = "Flee",
        version = "0.0.1",
        priority = 40,
        scene_path = LEVELS_PATH_PREFIX + "level4.tscn",
        platform_graph_player_names = [
            "momma",
            "duckling",
            "run_away_duckling",
            "fox",
        ],
    },
    "5": {
        name = "Waddle",
        version = "0.0.1",
        priority = 50,
        scene_path = LEVELS_PATH_PREFIX + "level5.tscn",
        platform_graph_player_names = [
            "momma",
            "duckling",
            "run_away_duckling",
            "porcupine",
            "fox",
        ],
    },
}


func _init().(ARE_LEVELS_SCENE_BASED) -> void:
    pass


#func _sanitize_level_config(config: Dictionary) -> void:
#    ._sanitize_level_config(config)


func get_level_config(level_id: String) -> Dictionary:
    return level_manifest[level_id]


func get_level_ids() -> Array:
    return level_manifest.keys()


func get_unlock_hint(level_id: String) -> String:
    if Gs.save_state.get_level_is_unlocked(level_id):
        return ""
    
    var previous_level_id := get_previous_level_id(level_id)
    if previous_level_id == "":
        Utils.error("If this is the first level, it should be unlocked")
        return ""
    
    var settings_key := MommaDuckLevel.get_level_fastest_time_settings_key(
            previous_level_id)
    if Gs.save_state.get_setting(settings_key, INF) != INF:
        return ""
    
    return "Finish %s" % get_level_config(previous_level_id).name


func get_previous_level_id(level_id: String) -> String:
    var level_number: int = get_level_config(level_id).number
    
    var level_numbers := []
    for level_id in get_level_ids():
        var config := get_level_config(level_id)
        level_numbers.push_back(config.number)
    level_numbers.sort()
    
    for i in level_numbers.size():
        if level_numbers[i] == level_number:
            if i == 0:
                return ""
            else:
                return _level_configs_by_number[level_numbers[i - 1]].id
    
    Utils.error("The given level_id is invalid: %s" % level_id)
    
    return ""


func get_suggested_next_level() -> String:
    # TODO
    var last_level_played_id := Gs.save_state.get_last_level_played()
    if last_level_played_id != "" and \
            level_manifest.has(last_level_played_id):
        return last_level_played_id
    else:
        return get_level_ids().front()
