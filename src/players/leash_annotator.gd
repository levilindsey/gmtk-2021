class_name LeashAnnotator
extends Node2D


const LEASH_COLOR := Color("c3ae6c33")
const LEASH_MAX_STRETCHED_COLOR := Color("FF220433")

const LEASH_WIDTH := 2.0
const LEASH_MAX_STRETCHED_WIDTH := 0.5

const LEASH_DETACH_DISTANCE_RATIO_TO_START_STRETCHING_AT := 0.33
const DISTANCE_TO_START_STRETCHING_AT := \
        Duck.LEASH_DETACH_DISTANCE * \
        LEASH_DETACH_DISTANCE_RATIO_TO_START_STRETCHING_AT
const DISTANCE_SQUARED_TO_START_STRETCHING_AT := \
        DISTANCE_TO_START_STRETCHING_AT * \
        DISTANCE_TO_START_STRETCHING_AT

var duck
var leash: Rope


func _init(duck) -> void:
    self.duck = duck
    self.leash = Rope.new()


func _physics_process(_delta: float) -> void:
    if !is_instance_valid(duck):
        return

    if duck.just_attached_to_leader:
        leash.on_new_attachment(duck.position, duck.leader.position)
    
    if duck.is_attached_to_leader:
        leash.update_end_positions(duck.position, duck.leader.position)
        leash.on_physics_frame()

    if duck.is_attached_to_leader or \
            duck.just_detached_from_leader:
        update()


func _draw() -> void:
    if !duck.is_attached_to_leader:
        return
    
    var vertices := PoolVector2Array()
    vertices.resize(leash.nodes.size())
    for i in leash.nodes.size():
        vertices[i] = leash.nodes[i].position
    
    var color: Color
    var width: float
    var distance_squared: float = \
            duck.position.distance_squared_to(duck.leader.position)
    if distance_squared > DISTANCE_SQUARED_TO_START_STRETCHING_AT:
        var distance: float = duck.position.distance_to(duck.leader.position)
        var stretch_distance := \
                Duck.LEASH_DETACH_DISTANCE - DISTANCE_TO_START_STRETCHING_AT
        var stretch_progress := \
                (distance - DISTANCE_TO_START_STRETCHING_AT) / stretch_distance
        stretch_progress = Gs.utils.ease_by_name(stretch_progress, "ease_in")
        color = lerp(LEASH_COLOR, LEASH_MAX_STRETCHED_COLOR, stretch_progress)
        width = lerp(LEASH_WIDTH, LEASH_MAX_STRETCHED_WIDTH, stretch_progress)
    else:
        color = LEASH_COLOR
        width = LEASH_WIDTH
    
    draw_polyline(
            vertices,
            color,
            width)
