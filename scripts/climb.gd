extends Node3D
#create a dialogue file in dialogue button above lol
var in_body = false
var balloon
var player_body

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("Jump") && in_body:
		player_body.global_position.y += 5.0 * delta
		player_body._gravity = 0
	if in_body && !Input.is_action_pressed("Jump"):
		player_body.velocity.y = 0
		player_body.global_position.y = player_body.global_position.y
	pass


func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		player_body = body
		in_body = true
		print("FUCK")
		
	pass # Replace with function body.


func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		in_body = false
		player_body._gravity = -30
	pass # Replace with function body.
