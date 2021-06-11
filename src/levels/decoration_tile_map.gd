tool
class_name DecorationTileMap
extends SurfacesTileMap


const DEFAULT_TILE_SET := \
        preload("res://src/levels/decoration_tile_set.tres")


func _ready() -> void:
    if tile_set == null:
        tile_set = DEFAULT_TILE_SET