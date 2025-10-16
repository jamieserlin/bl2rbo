extends HSlider

@export var audio_bus_name: String
var audio_bus_id

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	_on_value_changed(0.3)


func _on_value_changed(value: float) -> void:
	print("New Audio Value ", value)
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
