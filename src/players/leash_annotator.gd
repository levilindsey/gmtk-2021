class_name LeashAnnotator
extends Node2D


const LEASH_COLOR := Color("a37e3c")
const LEASH_WIDTH := 6.0

var duck


func _init(duck) -> void:
    self.duck = duck


func _physics_process(_delta: float) -> void:
    if is_instance_valid(duck) and \
            (duck.is_attached_to_leader or \
            duck.just_detached_from_leader):
        update()


func _draw() -> void:
    # FIXME: --------------- Add a nicer "weighty" physicsish animation to this.
    if !duck.is_attached_to_leader:
        return
    
    draw_line(
            duck.position,
            duck.leader.position,
            LEASH_COLOR,
            LEASH_WIDTH)
