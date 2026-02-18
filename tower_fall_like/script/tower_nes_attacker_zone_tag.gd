class_name TowerNesAttackerZoneTag
extends Area2D

@export var tag_group_name: String = "TowerNesAttackerZoneTagGroup"

func _ready():
    add_to_group(tag_group_name)