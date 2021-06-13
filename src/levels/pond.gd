tool
class_name Pond
extends Area2D


export var width_cell_count := 8 setget _set_width_cell_count


func _set_width_cell_count(value: int) -> void:
    width_cell_count = value
    $CollisionShape2D.shape.extents.x = width_cell_count * 32.0 / 2.0
