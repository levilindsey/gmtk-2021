class_name Rope
extends Reference


const NUMBER_OF_PHYSICS_FRAMES_BETWEEN_NODE_PHYSICS_FRAMES := 2
const NUMBER_OF_NEIGHBOR_CONSTRAINT_UPDATE_ITERATIONS_PER_FRAME := 50
const NODE_SOLVER_ITERATIONS := 20
const ROPE_LENGTH_TO_MAX_ATTACHMENT_DISTANCE_RATIO := 0.75
const NODE_MASS := 0.8
const NODE_DAMPING := 0.8
const DISTANCE_BETWEEN_NODES := 8.0
var NODE_COUNT := \
        Duck.LEASH_DETACH_DISTANCE * \
        ROPE_LENGTH_TO_MAX_ATTACHMENT_DISTANCE_RATIO / \
        DISTANCE_BETWEEN_NODES

var total_physics_frame_count := 0
var last_rope_physics_frame_index := 0
        
# Array<RopeNode>
var nodes: Array


func _init() -> void:
    _initialize_nodes()


func _initialize_nodes() -> void:
    assert(NODE_COUNT > 2)
    
    nodes = []
    nodes.resize(NODE_COUNT)
    
    # Instantiate nodes.
    for i in nodes.size():
        nodes[i] = RopeNode.new()
    
    # Assign neigbor references.
    
    var current_node: RopeNode = nodes[0]
    current_node.previous_node = null
    current_node.next_node = nodes[1]
    current_node.is_fixed = true
    
    for i in range(1, nodes.size() - 1):
        current_node = nodes[i]
        current_node.previous_node = nodes[i - 1]
        current_node.next_node = nodes[i + 1]
    
    current_node = nodes[nodes.size() - 1]
    current_node.previous_node = nodes[nodes.size() - 2]
    current_node.next_node = null
    current_node.is_fixed = true


func update_end_positions(
        start: Vector2,
        end: Vector2) -> void:
    nodes[0].position = start
    nodes[0].previous_position = start
    nodes[nodes.size() - 1].position = end
    nodes[nodes.size() - 1].previous_position = end


func on_physics_frame() -> void:
    if (total_physics_frame_count - last_rope_physics_frame_index) >= \
            NUMBER_OF_PHYSICS_FRAMES_BETWEEN_NODE_PHYSICS_FRAMES:
        last_rope_physics_frame_index = total_physics_frame_count
        _update_nodes()
    
    total_physics_frame_count += 1


func _update_nodes() -> void:
    for i in range(1, nodes.size() - 1):
        nodes[i].update_for_gravity()
    
    for iteration in NUMBER_OF_NEIGHBOR_CONSTRAINT_UPDATE_ITERATIONS_PER_FRAME:
        for i in range(1, nodes.size() - 1):
            nodes[i].update_for_neighbors()


func on_new_attachment(
        start: Vector2,
        end: Vector2) -> void:
    var displacement_between_neighbors := (end - start) / (nodes.size() - 1)
    
    var current_node: RopeNode = nodes[0]
    current_node.position = start
    current_node.previous_position = start
    
    current_node = nodes[nodes.size() - 1]
    current_node.position = end
    current_node.previous_position = end
    
    for i in range(1, nodes.size() - 1):
        var position := start + displacement_between_neighbors * i
        # Give a slight downward offset to ensure things spring downward at
        # the start.
        position.y += 0.01
        current_node = nodes[i]
        current_node.position = position
        current_node.previous_position = position


# Rope-simulation using Störmer–Verlet integration.
class RopeNode extends Reference:
    var NODE_TIME_STEP := \
            Gs.time.PHYSICS_TIME_STEP * \
            NUMBER_OF_PHYSICS_FRAMES_BETWEEN_NODE_PHYSICS_FRAMES
    
    var is_fixed := false
    
    var position := Vector2.INF
    var previous_position := Vector2.INF
    
    var previous_node: RopeNode
    var next_node: RopeNode
    
    
    # Update node according to gravity.
    func update_for_gravity() -> void:
        var displacement := position - previous_position
        previous_position = position
        
        position.x += displacement.x * NODE_DAMPING
        position.y += \
                displacement.y * NODE_DAMPING + \
                Gs.geometry.GRAVITY * NODE_MASS * \
                NODE_TIME_STEP * NODE_TIME_STEP
    
    
    # Update node according to neighbor constraints.
    func update_for_neighbors() -> void:
        if next_node != null:
            var displacement := next_node.position - position
            var distance := displacement.length()
            var direction := displacement.normalized()
            var diff := distance - DISTANCE_BETWEEN_NODES
            
            if !is_fixed:
                position.x += direction.x * diff * 0.25
                position.y += direction.y * diff * 0.25
            
            if !next_node.is_fixed:
                next_node.position.x -= direction.x * diff * 0.25
                next_node.position.y -= direction.y * diff * 0.25
        
        if previous_node != null:
            var displacement := previous_node.position - position
            var distance := displacement.length()
            var direction := displacement.normalized()
            var diff := distance - DISTANCE_BETWEEN_NODES
            
            if !is_fixed:
                position.x += direction.x * diff * 0.25
                position.y += direction.y * diff * 0.25
            
            if !previous_node.is_fixed:
                previous_node.position.x -= direction.x * diff * 0.25
                previous_node.position.y -= direction.y * diff * 0.25
