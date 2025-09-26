extends StaticBody2D

signal isClosed

func _ready() -> void:
	pass


func _on_trigger_player_entered() -> void:
	$AnimationPlayer.play("Active")
	await(get_tree().create_timer(1.3))
	$AnimationPlayer.play("Closed")
	emit_signal("isClosed")
