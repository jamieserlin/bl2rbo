extends Node

@onready var objects
@export var dissolve = 2
var enviro_1
var enviro_2
var change_enviro = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enviro_1 = get_tree().get_first_node_in_group("enviro_1")
	enviro_2 = get_tree().get_first_node_in_group("enviro_2")
	objects = get_tree().get_nodes_in_group("dissolve")
	change_enviro = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if change_enviro &&  enviro_1 !=null && enviro_2 != null:
		if dissolve >= 0:
			dissolve -= 0.3 * delta
			enviro_2.show()
		else:
			enviro_1.hide()
		for i in objects:
			i.get_material_override().set_shader_parameter("dissolveSlider", dissolve)
