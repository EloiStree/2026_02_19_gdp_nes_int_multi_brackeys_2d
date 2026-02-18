class_name TowerNesAttackableZone
extends Area2D

signal on_attacked_detected()


@export var listen_to_group_name: String = "TowerNesAttackerZoneTagGroup"
@export var use_print_debug:bool

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func notify_attacked():
	on_attacked_detected.emit()
	if use_print_debug:
		print("Attacked detected in attackable zone by body: ",self)
 
func _on_body_entered(body):
	if body.is_in_group(listen_to_group_name):
		notify_attacked()
		
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(listen_to_group_name):
		notify_attacked()
		
