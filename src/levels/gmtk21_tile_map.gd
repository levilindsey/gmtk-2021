tool
class_name Gmtk21TileMap
extends SurfacesTileMap


const DEFAULT_TILE_SET := \
        preload("res://src/levels/gmtk21_tile_set.tres")


func _ready() -> void:
    if tile_set == null:
        tile_set = DEFAULT_TILE_SET
