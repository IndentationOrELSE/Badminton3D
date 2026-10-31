extends RigidBody3D

signal landed(pos: Vector3)
signal hit_net()
signal was_hit(by: String)

const DRAG = 0.15

var in_play := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("shuttlecock")
	body_entered.connect(_on_body_entered)

func serve(pos: Vector3) -> void:
	# initialisation, linear + angular velocity, position
	freeze = true
	in_play = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_position = pos
	
func _on_body_entered(body: Node) -> void:
	if not in_play:
		return
	if body.is_in_group("floor"):
		in_play = false
		landed.emit(global_position)
	if body.is_in_group("net"):
		hit_net.emit()
		
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# velocity, speed
	var v := state.linear_velocity
	var speed := v.length()
	# drag
	if speed > 0.0001:
		state.linear_velocity -= v * speed * DRAG * state.step
	else:
		pass
	
func apply_hit(direction: Vector3, force: float, by: String) -> void:
	# initialisation, linear + angular velocity, position
	freeze = false
	in_play = true
	angular_velocity = Vector3.ZERO
	linear_velocity = direction * force 
	was_hit.emit(by)
