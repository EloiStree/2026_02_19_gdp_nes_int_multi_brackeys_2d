extends Node

@export var node_to_destroy: Node

func kill_by_destroying():
	if node_to_destroy:
		node_to_destroy.queue_free()
