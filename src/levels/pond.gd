tool
class_name Pond
extends Area2D


export var width := 256.0 setget _set_width


func _set_width(value: float) -> void:
    width = value
    $CollisionShape2D.shape.extents.x = width / 2.0
