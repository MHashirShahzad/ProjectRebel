@tool
class_name ColoredCollisionShape3D extends CollisionShape3D

## Provides some extra visual options for [CollisionShape3D].
##
## [ColoredCollisionShape3D] (CCS) can display an image on the [CollisionShape3D], tint the color, change the opacity and much more.
##

## This will be used as the color on the [CollisionShape3D]. Will also tint [param _image].
@export var _color: Color = Color.WHITE
## This will be used as a texture on the [CollisionShape3D]
@export var _image: CompressedTexture2D
## The [param UV scale] used for [param _image]. 
@export var _image_scale: Vector3 = Vector3(1, 1, 1)
## The [param opacity] of the internal [MeshInstance3D].[br] [br]Will be ignored if [param _use_texture_transparency] is [code]true[/code] 
@export_range(0, 1) var _mesh_opacity: float = 0.014 
## When enabled the alpha channel of [param _image] will be used.[br] [br]This disables [param _mesh_opacity].
@export var _use_texture_transparency: bool 
## Use triplanar mapping to display [param _image].
@export var _triplanar_mapping: bool
## Use world coordinates for triplanar mapping to display [param _image].
@export var _world_triplanar: bool

@export var override_mesh_opacity : float = 0.014

@onready var _null_shape_mesh: Mesh = BoxMesh.new()

var _previous_shape: Shape3D
var _visualizer_mesh: MeshInstance3D
var _visualizer_material: StandardMaterial3D

static var debug_enabled : bool = false



func _ready() -> void:
	_null_shape_mesh.size = Vector3(0, 0, 0)
	_initialize_colored_collision_shape()
	_visualizer_mesh.mesh = _null_shape_mesh
	
	

func _initialize_colored_collision_shape() -> void:
	_visualizer_mesh = _create_visualizer_mesh_instance()
	add_child(_visualizer_mesh, false, Node.INTERNAL_MODE_FRONT)
	_visualizer_material = _create_visualizer_material()

func _create_visualizer_mesh_instance() -> MeshInstance3D:
	var _mesh_imposter: MeshInstance3D
	_mesh_imposter = MeshInstance3D.new()
	_mesh_imposter.set_meta("IsCCSVisualizer", true)
	_mesh_imposter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return _mesh_imposter

func _create_visualizer_material() -> StandardMaterial3D:
	var _material_imposter: StandardMaterial3D = StandardMaterial3D.new()
	_material_imposter.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material_imposter.disable_ambient_light = true
	_material_imposter.disable_receive_shadows = true
	return _material_imposter

func _change_mesh_to(_mesh) -> void:
	_visualizer_mesh.mesh = _mesh.new()
	_visualizer_mesh.mesh.surface_set_material(0, _visualizer_material)

func _update_visualizer_mesh_transform() -> void:
	if _visualizer_mesh.mesh is SphereMesh && shape is SphereShape3D:
		_visualizer_mesh.mesh.height = shape.radius * 2
		_visualizer_mesh.mesh.radius = shape.radius
	if _visualizer_mesh.mesh is BoxMesh && shape is BoxShape3D:
		_visualizer_mesh.mesh.size = shape.size
	if _visualizer_mesh.mesh is CylinderMesh && shape is CylinderShape3D:
		_visualizer_mesh.mesh.top_radius = shape.radius
		_visualizer_mesh.mesh.bottom_radius = shape.radius
		_visualizer_mesh.mesh.height = shape.height
	if _visualizer_mesh.mesh is CapsuleMesh && shape is CapsuleShape3D:
		_visualizer_mesh.mesh.height = shape.height
		_visualizer_mesh.mesh.radius = shape.radius

func _update_visualizer_material() -> void:
	if _use_texture_transparency:
		_visualizer_material.cull_mode = BaseMaterial3D.CULL_BACK
	else:
		_visualizer_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	_visualizer_material.albedo_color = _color
	_visualizer_mesh.transparency = 1 - _mesh_opacity
	
	if _use_texture_transparency:
		_visualizer_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	else:
		_visualizer_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	
	_visualizer_material.uv1_triplanar = _triplanar_mapping
	_visualizer_material.uv1_world_triplanar = _world_triplanar
	_visualizer_material.uv1_scale = _image_scale

func _process(_delta: float) -> void:
	if !debug_enabled:
		_mesh_opacity = 0
	else:
		_mesh_opacity = override_mesh_opacity
	
	if not _visualizer_mesh.mesh == null && not shape == null:
		_update_visualizer_material()
		_update_visualizer_mesh_transform()
	
	if shape == null:
		_visualizer_mesh.mesh = _null_shape_mesh
	
	# set the image if there is any
	if not _image == null:
		_visualizer_material.albedo_texture = _image
	
	# check if the shape was swapped out and change the shape accordingly 
	if not shape == _previous_shape:
		if not _visualizer_mesh == null:
			if shape is SphereShape3D:
				_change_mesh_to(SphereMesh)
			if shape is BoxShape3D:
				_change_mesh_to(BoxMesh)
			if shape is CapsuleShape3D:
				_change_mesh_to(CapsuleMesh)
			if shape is CylinderShape3D:
				_change_mesh_to(CylinderMesh)
		else:
			_change_mesh_to(_null_shape_mesh)
	
	_previous_shape = shape

## Reveses the debug enabled variable
static func debug():
	if debug_enabled:
		debug_enabled = false
	else:
		debug_enabled = true
