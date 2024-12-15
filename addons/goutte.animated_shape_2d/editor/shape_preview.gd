@tool
extends CollisionShape3D

## Added to the temporary CollisionShape3D created in the 3D view of the Editor.
## Used to recover the position and size changes, since item_rect_changed NOPE.
## Note that we don't need the size of the shape, it's already propagated.
## This is only for the position, and perhaps later on rotation and scale ?


signal rectangle_changed


func _ready():
	set_notify_local_transform(true)


func _notification(what: int):
	if what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		rectangle_changed.emit()
